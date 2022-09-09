require "rails_helper"

describe Polls::Answers::PrioritizationListComponent do
  let(:user) { create(:user) }
  let(:question) { create(:poll_question_prioritized, :with_answers, with_answers_count: 3) }

  before do
    sign_in(user)
  end

  it "does not render the list for unique and multiple questions" do
    factories = %i[poll_question poll_question_unique poll_question_multiple]
    question = create(factories.sample, :with_answers)
    create(:poll_answer, author: user, question: question)

    render_inline Polls::Answers::PrioritizationListComponent.new(question)

    expect(page).not_to have_selector "ol"
  end

  it "does not render the list when user not answered yet" do
    render_inline Polls::Answers::PrioritizationListComponent.new(question)

    expect(page).not_to have_selector "ol"
  end

  it "renders the list when user already answered" do
    create(:poll_answer, author: user, question: question, answer: "Answer A")

    render_inline Polls::Answers::PrioritizationListComponent.new(question)

    expect(page).to have_selector "ol"
  end

  it "renders the answers in creation order" do
    create(:poll_answer, author: user, question: question, answer: "Answer C")
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    create(:poll_answer, author: user, question: question, answer: "Answer B")

    render_inline Polls::Answers::PrioritizationListComponent.new(question)

    expect("Answer C").to appear_before("Answer A")
    expect("Answer A").to appear_before("Answer B")
  end

  it "renders class and data to work with sortable feature" do
    create(:poll_answer, author: user, question: question, answer: "Answer C")
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    create(:poll_answer, author: user, question: question, answer: "Answer B")

    render_inline Polls::Answers::PrioritizationListComponent.new(question)

    expect(page).to have_selector "ol.sortable"
    question.question_answers.each do |question_answer|
      expect(page).to have_selector "li[data-answer-id='#{question_answer.title}']"
    end
  end
end
