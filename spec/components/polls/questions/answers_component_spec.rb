require "rails_helper"

describe Polls::Questions::AnswersComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }

  describe "unique answers" do
    let(:factory) { %i[poll_question poll_question_unique].sample }
    let(:question) { create(factory, :with_answers, with_answers_count: 2, poll: poll) }

    it "renders answers in given order" do
      question.question_answers.first.update!(given_order: 2)
      question.question_answers.last.update!(given_order: 1)

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect("Answer B").to appear_before "Answer A"
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
      expect(page).to have_button "Vote Answer B"
    end

    it "hides current answer and shows buttons in successive sessions" do
      user = create(:user, :verified)
      create(:poll_answer, author: user, question: question, answer: "Answer A")
      allow(user).to receive(:current_sign_in_at).and_return(Time.current)
      sign_in(user)

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_button "Vote Answer A"
      expect(page).to have_button "Vote Answer B"
    end
  end

  describe "multiple and prioritized answers" do
    let(:votation_type) { %w[multiple prioritized].sample }
    let(:question) do
      create(:"poll_question_#{votation_type}", :with_answers, with_answers_count: 3, max_votes: 2, poll: poll)
    end

    it "renders buttons to vote question answers" do
      sign_in(create(:user, :verified))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_button "Vote Answer A"
      expect(page).to have_button "Vote Answer B"
      expect(page).to have_button "Vote Answer C"
    end

    it "renders buttons to remove current user answers" do
      author = create(:user, :verified)
      create(:poll_answer, question: question, author: author, answer: "Answer B")
      create(:poll_answer, question: question, author: author, answer: "Answer C")
      sign_in(author)

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_button "Vote Answer A"
      expect(page).to have_button "You have voted Answer B"
      expect(page).to have_button "You have voted Answer C"
    end

    it "does not render prioritization list for multiple questions" do
      author = create(:user, :verified)
      question = create(:poll_question_multiple, :with_answers, with_answers_count: 3, max_votes: 2)
      create(:poll_answer, question: question, author: author, answer: "Answer B")
      create(:poll_answer, question: question, author: author, answer: "Answer C")
      sign_in(author)

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).not_to have_selector "ol"
    end
  end

  describe "prioritized answers" do
    let(:question) do
      create(:poll_question_prioritized, :with_answers, with_answers_count: 3, max_votes: 2, poll: poll)
    end

    it "does not render the prioritization list when user not answered yet" do
      sign_in(create(:user, :verified))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).not_to have_selector "ol"
    end

    it "renders answers priorized list by order when user already answered" do
      user = create(:user, :verified)
      create(:poll_answer, author: user, question: question, answer: "Answer B", order: 2)
      create(:poll_answer, author: user, question: question, answer: "Answer C", order: 1)
      sign_in(user)

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_selector "ol"
      items = page.all "ol li"
      expect(items.first.text).to match "Answer C"
      expect(items.last.text).to match "Answer B"
    end
  end

  it "when user is not signed in, renders answers links pointing to user sign in path" do
    question = create(:poll_question, :with_answers, with_answers_count: 2, poll: poll)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link "Answer A", href: new_user_session_path
    expect(page).to have_link "Answer B", href: new_user_session_path
  end

  it "when user is not verified, renders answers links pointing to user verification in path" do
    question = create(:poll_question, :with_answers, with_answers_count: 2, poll: poll)
    sign_in(create(:user))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link "Answer A", href: verification_path
    expect(page).to have_link "Answer B", href: verification_path
  end

  it "when user already voted in booth it renders disabled answers" do
    question = create(:poll_question, :with_answers, with_answers_count: 2, poll: poll)
    user = create(:user, :level_two)
    create(:poll_voter, :from_booth, poll: poll, user: user)
    sign_in(user)

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
