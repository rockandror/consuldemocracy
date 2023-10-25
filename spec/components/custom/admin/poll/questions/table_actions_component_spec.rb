require "rails_helper"

describe Admin::Poll::Questions::TableActionsComponent, :admin do
  it "does not display the 'Edit Answers' action if the question type is 'open'" do
    question = create(:poll_question_open, poll: create(:poll))

    render_inline Admin::Poll::Questions::TableActionsComponent.new(question)

    expect(page).not_to have_link "Edit answers"
  end
end
