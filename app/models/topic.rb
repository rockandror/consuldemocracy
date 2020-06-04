class Topic < ApplicationRecord
  include ActsAsParanoidAliases
  include Notifiable
  include Followable
  include Flaggable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  
  belongs_to :community
  belongs_to :author, -> { with_hidden }, class_name: "User", foreign_key: "author_id"

  has_many :comments, as: :commentable

  attr_accessor :as_moderator, :as_administrator

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :sort_by_hot_score,        -> { reorder(hot_score: :desc) }
  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_by_most_commented, -> { reorder(comments_count: :desc) }
  scope :sort_by_recommendations,  -> { order(cached_votes_total: :desc) }
  scope :public_for_api,           -> { all }
  scope :not_as_admin_or_moderator, -> do
    where("administrator_id IS NULL").where("moderator_id IS NULL")
  end
  scope :sort_by_flags, -> { order(flags_count: :desc, updated_at: :desc) }


  def self.rank(topic)
    return 0 if topic.blank?
    connection.select_all(<<-SQL).first["rank"]
      SELECT ranked.rank FROM (
        SELECT id, rank() OVER (ORDER BY confidence_score DESC)
        FROM topics
      ) AS ranked
      WHERE id = #{topic.id}
      SQL
  end

  def as_administrator?
    administrator_id.present?
  end

  def as_moderator?
    moderator_id.present?
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(self)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
  end

  def total_votes
    cached_votes_total
  end

  def votes_score
    cached_votes_score
  end

  def total_anonymous_votes
    cached_anonymous_votes_total
  end

  def editable?
    total_votes <= Setting["max_votes_for_topic_edit"].to_i
  end

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def register_vote(user, vote_value)
    vote_by(voter: user, vote: vote_value) if votable_by?(user)
  end

  def anonymous_votes_ratio
    return 0 if cached_votes_total == 0
    (cached_anonymous_votes_total.to_f / cached_votes_total) * 100
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  def self.public_columns_for_api
    %w[id
       title
       description
       created_at
       cached_votes_total
       cached_votes_up
       cached_votes_down
       hot_score
       confidence_score
       comments_count]
  end

  def public_for_api?
    hidden? ? false : true
  end

end
