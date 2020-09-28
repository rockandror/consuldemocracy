class Legislation::QuestionOption < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :value, touch: true
  translates :other, touch: true
  translates :is_range, touch: true
  translates :is_number, touch: true
  translates :range_first, touch: true
  translates :range_last, touch: true
  include Globalizable

  belongs_to :question, class_name: "Legislation::Question", foreign_key: "legislation_question_id", inverse_of: :question_options
  has_many :answers, class_name: "Legislation::Answer", foreign_key: "legislation_question_id", dependent: :destroy, inverse_of: :question

  validates :question, presence: true
  validates_translation :value, presence: true, if: -> {self.other.to_s != "true" && self.is_range.to_s != "true" && self.is_number.to_s != "true"}
  validates_translation :range_first, presence: true, if: -> {self.is_range}
  validates_translation :range_last, presence: true, if: -> {self.is_range}
end
