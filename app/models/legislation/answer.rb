class Legislation::Answer < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :question, class_name: "Legislation::Question", foreign_key: "legislation_question_id",
                        inverse_of: :answers, counter_cache: true
  belongs_to :question_option, class_name: "Legislation::QuestionOption", foreign_key: "legislation_question_option_id",
                               inverse_of: :answers, counter_cache: true
  belongs_to :user, dependent: :destroy, inverse_of: :legislation_answers

  validates :question, presence: true#, uniqueness: { scope: :user_id}
  validates :question_option, presence: true
  validates :user, presence: true

  scope :legislation_by_question_option,  -> (question_option) { where(legislation_question_option_id: question_option)}
  scope :legislation_other, -> { where("value_other is not NULL AND value_other != ''")}
  scope :legislation_range, -> { where("value_range is not NULL")}


 

end
