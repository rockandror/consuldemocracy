require "rails_helper"

describe Polls::Questions::AnswersComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, :with_answers, with_answers_count: 2, poll: poll) }

  it "renders answers in given order" do
    question = create(:poll_question)
    create(:poll_question_answer, question: question, given_order: 1, title: "Answer C")
    create(:poll_question_answer, question: question, given_order: 2, title: "Answer A")
    create(:poll_question_answer, question: question, given_order: 3, title: "Answer B")

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect("Answer C").to appear_before("Answer A")
    expect("Answer A").to appear_before("Answer B")
  end

  it "renders buttons to vote question answers" do
    sign_in(create(:user, :verified))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_button "Answer A"
    expect(page).to have_button "Answer B"
  end

  it "renders a span instead of a button for existing user answers" do
    user = create(:user, :verified)
    allow(user).to receive(:current_sign_in_at).and_return(user.created_at)
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector "span", text: "Answer A"
    expect(page).not_to have_button "Answer A"
    expect(page).to have_button "Answer B"
  end

  it "hides current answer and shows buttons in successive sessions" do
    user = create(:user, :verified)
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    allow(user).to receive(:current_sign_in_at).and_return(Time.current)
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_button "Answer A"
    expect(page).to have_button "Answer B"
  end

  it "when user is not signed in, renders answers links pointing to user sign in path" do
    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link "Answer A", href: new_user_session_path
    expect(page).to have_link "Answer B", href: new_user_session_path
  end

  it "when user is not verified, renders answers links pointing to user verification in path" do
    sign_in(create(:user))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link "Answer A", href: verification_path
    expect(page).to have_link "Answer B", href: verification_path
  end

  it "when user already voted in booth it renders disabled answers" do
    user = create(:user, :level_two)
    create(:poll_voter, :from_booth, poll: poll, user: user)
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector "span.disabled", text: "Answer A"
    expect(page).to have_selector "span.disabled", text: "Answer B"
  end

  it "user cannot vote when poll expired it renders disabled answers" do
    question = create(:poll_question, :with_answers, with_answers_count: 2, poll: create(:poll, :expired))
    sign_in(create(:user, :level_two))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector "span.disabled", text: "Answer A"
    expect(page).to have_selector "span.disabled", text: "Answer B"
  end

  describe "geozone" do
    let(:poll) { create(:poll, geozone_restricted: true) }
    let(:geozone) { create(:geozone) }
    let(:question) { create(:poll_question, :with_answers, with_answers_count: 2, poll: poll) }

    it "when geozone which is not theirs it renders disabled answers" do
      poll.geozones << geozone
      sign_in(create(:user, :level_two))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_selector "span.disabled", text: "Answer A"
      expect(page).to have_selector "span.disabled", text: "Answer B"
    end

    it "reading a same-geozone poll it renders buttons to vote question answers" do
      poll.geozones << geozone
      sign_in(create(:user, :level_two, geozone: geozone))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_button "Answer A"
      expect(page).to have_button "Answer B"
    end
  end
end
