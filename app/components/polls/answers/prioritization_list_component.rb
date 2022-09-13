class Polls::Answers::PrioritizationListComponent < ApplicationComponent
  attr_reader :question
  delegate :current_user, to: :helpers

  def initialize(question)
    @question = question
  end

  def render?
    question.prioritized? && user_answers.any?
  end

  def user_answers
    question.answers.by_author(current_user.id).order(:order)
  end

  def move_up_button(answer)
    index = user_answers.index(answer)
    return if index == 0

    new_order = user_answers.to_a
    new_order[index], new_order[index - 1] = new_order[index - 1], new_order[index]
    text = t("polls.show.prioritized_list.move_up", answer: answer.answer)
    button(new_order.map(&:answer), "angle-up", text)
  end

  def move_down_button(answer)
    index = user_answers.index(answer)
    return if index == user_answers.size - 1

    new_order = user_answers.to_a
    new_order[index], new_order[index + 1] = new_order[index + 1], new_order[index]
    text = t("polls.show.prioritized_list.move_down", answer: answer.answer)
    button(new_order.map(&:answer), "angle-down", text)
  end

  private

    def button(ordered_list, icon, text)
      button_to prioritize_answers_question_path(question),
                title: text,
                params: { ordered_list: ordered_list },
                remote: true do
        tag.span(class: "aria-hidden icon-#{icon}") + tag.span(text, class: "show-for-sr")
      end
    end
end
