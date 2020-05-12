class Topic < ApplicationRecord
  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

  belongs_to :community
  belongs_to :author, -> { with_hidden }, class_name: "User", foreign_key: "author_id"

  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_by_most_commented, -> { reorder(comments_count: :desc) }
  scope :sort_by_recommendations,  -> { order(cached_votes_total: :desc) }
  scope :public_for_api,           -> { all }

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

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def register_vote(user, vote_value)
    vote_by(voter: user, vote: vote_value) if votable_by?(user)
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

  def register_vote(user, vote_value)
    if votable_by?(user)
      Topic.increment_counter(:cached_anonymous_votes_total, id) if user.unverified? && !user.voted_for?(self)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    return false unless user
    return false if ProbeOption.where(topic: self).present?
    total_votes <= 100 ||
      !user.unverified? ||
      Setting["max_ratio_anon_votes_on_topics"].to_i == 100 ||
      anonymous_votes_ratio < Setting["max_ratio_anon_votes_on_topics"].to_i ||
      user.voted_for?(self)
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
       comments_count]
  end

  def public_for_api?
    hidden? ? false : true
  end

end
