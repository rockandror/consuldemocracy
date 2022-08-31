require "rails_helper"

describe Polls::Questions::AnswersComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, poll: poll) }

  it "renders answers in given order" do
    create(:poll_question_answer, question: question, title: "Answer A", given_order: 2)
    create(:poll_question_answer, question: question, title: "Answer B", given_order: 1)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect("Answer B").to appear_before("Answer A")
  end

  it "renders links to vote question answers" do
    sign_in(create(:user, :verified))
    create(:poll_question_answer, question: question, title: "Answer A")
    create(:poll_question_answer, question: question, title: "Answer B")

    render_inline Polls::Questions::AnswersComponent.new(question)

    href_a = answer_question_path(question, answer: "Answer A")
    expect(page).to have_link("Answer A", href: href_a)
    href_b = answer_question_path(question, answer: "Answer B")
    expect(page).to have_link("Answer B", href: href_b)
  end

  it "renders a span instead of a link for existing user answers" do
    user = create(:user, :verified)
    allow(user).to receive(:current_sign_in_at).and_return(user.created_at)
    sign_in(user)
    create(:poll_question_answer, question: question, title: "Answer A")
    create(:poll_question_answer, question: question, title: "Answer B")
    create(:poll_answer, author: user, question: question, answer: "Answer A")

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector("span", text: "Answer A")
    expect(page).not_to have_link("Answer A")
    href_b = answer_question_path(question, answer: "Answer B")
    expect(page).to have_link("Answer B", href: href_b)
  end

  it "hides current answer and shows links in successive sessions" do
    user = create(:user, :verified)
    sign_in(user)
    create(:poll_question_answer, question: question, title: "Answer A")
    create(:poll_question_answer, question: question, title: "Answer B")
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    allow(user).to receive(:current_sign_in_at).and_return(Time.current)

    render_inline Polls::Questions::AnswersComponent.new(question)

    href_a = answer_question_path(question, answer: "Answer A")
    expect(page).to have_link("Answer A", href: href_a)
    href_b = answer_question_path(question, answer: "Answer B")
    expect(page).to have_link("Answer B", href: href_b)
  end

  it "when user is not signed in, renders answers links pointing to user sign in path" do
    create(:poll_question_answer, question: question, title: "Answer A")
    create(:poll_question_answer, question: question, title: "Answer B")

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link("Answer A", href: new_user_session_path)
    expect(page).to have_link("Answer B", href: new_user_session_path)
  end

  it "when user is not verified, renders answers links pointing to user verification in path" do
    sign_in(create(:user))
    create(:poll_question_answer, question: question, title: "Answer A")
    create(:poll_question_answer, question: question, title: "Answer B")

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link("Answer A", href: verification_path)
    expect(page).to have_link("Answer B", href: verification_path)
  end

  it "when user already voted in booth it renders disabled answers" do
    user = create(:user, :level_two)
    sign_in(user)
    create(:poll_question_answer, question: question, title: "Answer A")
    create(:poll_question_answer, question: question, title: "Answer B")
    create(:poll_voter, :from_booth, poll: poll, user: user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector("span.disabled", text: "Answer A")
    expect(page).to have_selector("span.disabled", text: "Answer B")
  end
end
