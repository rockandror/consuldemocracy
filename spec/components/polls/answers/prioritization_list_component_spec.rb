require "rails_helper"

describe Polls::Answers::PrioritizationListComponent do
  include Rails.application.routes.url_helpers
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

  it "renders buttons to move answers up and down the list" do
    create(:poll_answer, author: user, question: question, answer: "Answer C")
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    create(:poll_answer, author: user, question: question, answer: "Answer B")

    render_inline Polls::Answers::PrioritizationListComponent.new(question)

    first_element = page.find("li:first")
    expect(first_element).to have_button "Reorder list. Move answer \"Answer C\" down."
    expect(first_element).not_to have_button "Reorder list. Move answer \"Answer C\" up."
    move_down_button_form = first_element.find("form")
    expect(move_down_button_form["action"]).to eq(prioritize_answers_question_path(question))
    hidden_fields = move_down_button_form.all("input[name='ordered_list[]']", visible: false)
    expect(hidden_fields[0].value).to eq("Answer A")
    expect(hidden_fields[1].value).to eq("Answer C")
    expect(hidden_fields[2].value).to eq("Answer B")

    middle_element = page.find("li:nth-child(2)")
    expect(middle_element).to have_button "Reorder list. Move answer \"Answer A\" up."
    move_up_button_form = middle_element.find("form:first")
    expect(move_up_button_form["action"]).to eq(prioritize_answers_question_path(question))
    hidden_fields = move_up_button_form.all("input[name='ordered_list[]']", visible: false)
    expect(hidden_fields[0].value).to eq("Answer A")
    expect(hidden_fields[1].value).to eq("Answer C")
    expect(hidden_fields[2].value).to eq("Answer B")

    expect(middle_element).to have_button "Reorder list. Move answer \"Answer A\" down."
    move_down_button_form = middle_element.find("form:last")
    expect(move_down_button_form["action"]).to eq(prioritize_answers_question_path(question))
    hidden_fields = move_down_button_form.all("input[name='ordered_list[]']", visible: false)
    expect(hidden_fields[0].value).to eq("Answer C")
    expect(hidden_fields[1].value).to eq("Answer B")
    expect(hidden_fields[2].value).to eq("Answer A")

    last_element = page.find("li:last")
    expect(last_element).not_to have_button "Reorder list. Move answer \"Answer B\" down."
    expect(last_element).to have_button "Reorder list. Move answer \"Answer B\" up."
    move_up_button_form = last_element.find("form")
    expect(move_up_button_form["action"]).to eq(prioritize_answers_question_path(question))
    hidden_fields = move_up_button_form.all("input[name='ordered_list[]']", visible: false)
    expect(hidden_fields[0].value).to eq("Answer C")
    expect(hidden_fields[1].value).to eq("Answer B")
    expect(hidden_fields[2].value).to eq("Answer A")
  end
end
