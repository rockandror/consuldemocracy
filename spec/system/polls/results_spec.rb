require "rails_helper"

describe "Poll Results" do
  scenario "List each Poll question" do
    user1 = create(:user, :level_two)
    user2 = create(:user, :level_two)
    user3 = create(:user, :level_two)

    poll = create(:poll, results_enabled: true)
    question1 = create(:poll_question, poll: poll)
    answer1 = create(:poll_question_answer, question: question1, title: "Yes")
    answer2 = create(:poll_question_answer, question: question1, title: "No")

    question2 = create(:poll_question, poll: poll)
    answer3 = create(:poll_question_answer, question: question2, title: "Blue")
    answer4 = create(:poll_question_answer, question: question2, title: "Green")
    answer5 = create(:poll_question_answer, question: question2, title: "Yellow")

    login_as user1
    vote_for_poll_via_web(poll, question1, "Yes")
    vote_for_poll_via_web(poll, question2, "Blue")
    logout

    login_as user2
    vote_for_poll_via_web(poll, question1, "Yes")
    vote_for_poll_via_web(poll, question2, "Green")
    logout

    login_as user3
    vote_for_poll_via_web(poll, question1, "No")
    vote_for_poll_via_web(poll, question2, "Yellow")
    logout

    travel_to(poll.ends_at + 1.day)

    visit results_poll_path(poll)

    expect(page).to have_content(question1.title)
    expect(page).to have_content(question2.title)

    within("#question_#{question1.id}_results_table") do
      expect(find("#answer_#{answer1.id}_result")).to have_content("2 (66.67%)")
      expect(find("#answer_#{answer2.id}_result")).to have_content("1 (33.33%)")
    end

    within("#question_#{question2.id}_results_table") do
      expect(find("#answer_#{answer3.id}_result")).to have_content("1 (33.33%)")
      expect(find("#answer_#{answer4.id}_result")).to have_content("1 (33.33%)")
      expect(find("#answer_#{answer5.id}_result")).to have_content("1 (33.33%)")
    end
  end

  scenario "Poll questions with multiple answers" do
    poll = create(:poll, results_enabled: true)
    question = create(:poll_question_multiple, :with_answers, with_answers_count: 6, poll: poll)
    user1 = create(:user)
    create(:poll_answer, question: question, author: user1, answer: "Answer A", order: 1)
    create(:poll_answer, question: question, author: user1, answer: "Answer B", order: 2)
    create(:poll_answer, question: question, author: user1, answer: "Answer C", order: 3)
    user2 = create(:user)
    create(:poll_answer, question: question, author: user2, answer: "Answer C", order: 1)
    create(:poll_answer, question: question, author: user2, answer: "Answer D", order: 2)
    create(:poll_answer, question: question, author: user2, answer: "Answer E", order: 3)
    user3 = create(:user)
    create(:poll_answer, question: question, author: user3, answer: "Answer C", order: 1)
    create(:poll_answer, question: question, author: user3, answer: "Answer B", order: 2)
    answer1, answer2, answer3, answer4, answer5, answer6 = question.question_answers.order(:id)
    poll.update_columns ends_at: 1.day.ago
    visit results_poll_path(poll)

    expect(page).to have_content(question.title)

    within("#question_#{question.id}_results_table") do
      expect(find("#answer_#{answer1.id}_result")).to have_content("1 (12.5%)")
      expect(find("#answer_#{answer2.id}_result")).to have_content("2 (25.0%)")
      expect(find("#answer_#{answer3.id}_result")).to have_content("3 (37.5%)")
      expect(find("#answer_#{answer4.id}_result")).to have_content("1 (12.5%)")
      expect(find("#answer_#{answer5.id}_result")).to have_content("1 (12.5%)")
      expect(find("#answer_#{answer6.id}_result")).to have_content("0 (0.0%)")
    end
  end

  scenario "Poll questions with prioritized answers" do
    poll = create(:poll, results_enabled: true)
    question = create(:poll_question_prioritized, :with_answers, with_answers_count: 6, poll: poll)
    user1 = create(:user)
    create(:poll_answer, question: question, author: user1, answer: "Answer A", order: 1)
    create(:poll_answer, question: question, author: user1, answer: "Answer B", order: 2)
    create(:poll_answer, question: question, author: user1, answer: "Answer C", order: 3)
    user2 = create(:user)
    create(:poll_answer, question: question, author: user2, answer: "Answer C", order: 1)
    create(:poll_answer, question: question, author: user2, answer: "Answer D", order: 2)
    create(:poll_answer, question: question, author: user2, answer: "Answer E", order: 3)
    user3 = create(:user)
    create(:poll_answer, question: question, author: user3, answer: "Answer C", order: 1)
    create(:poll_answer, question: question, author: user3, answer: "Answer B", order: 2)
    answer1, answer2, answer3, answer4, answer5, answer6 = question.question_answers.order(:id)
    poll.update_columns ends_at: 1.day.ago

    visit results_poll_path(poll)

    expect(page).to have_content(question.title)

    within("#question_#{question.id}_results_table") do
      expect(find("#answer_#{answer1.id}_result")).to have_content("3 (17.65%)")
      expect(find("#answer_#{answer2.id}_result")).to have_content("4 (23.53%)")
      expect(find("#answer_#{answer3.id}_result")).to have_content("7 (41.18%)")
      expect(find("#answer_#{answer4.id}_result")).to have_content("2 (11.76%)")
      expect(find("#answer_#{answer5.id}_result")).to have_content("1 (5.88%)")
      expect(find("#answer_#{answer6.id}_result")).to have_content("0 (0.0%)")
    end
  end

  scenario "Results for polls with questions but without answers" do
    poll = create(:poll, :expired, results_enabled: true)
    question = create(:poll_question, poll: poll)

    visit results_poll_path(poll)

    expect(page).to have_content question.title
  end
end
