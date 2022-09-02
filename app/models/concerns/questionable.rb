module Questionable
  extend ActiveSupport::Concern

  included do
    has_one :votation_type, as: :questionable, dependent: :destroy
    accepts_nested_attributes_for :votation_type
    delegate :max_votes, :multiple?, :prioritized?, :vote_type, to: :votation_type, allow_nil: true
  end

  def unique?
    votation_type.nil? || votation_type.unique?
  end

  def find_or_initialize_user_answer(user, title)
    answer = answers.find_or_initialize_by(find_by_attributes(user, title))
    answer.answer = title
    answer
  end

  private

    def find_by_attributes(user, title)
      case vote_type
      when "unique", nil
        { author: user }
      when "multiple"
        { author: user, answer: title }
      when "prioritized"
        if answers.by_author(user.id).empty?
          order = 1
        else
          order = answers.by_author(user.id).order(:order).last.order + 1
        end
        { author: user, answer: title, order: order }
      end
    end
end
