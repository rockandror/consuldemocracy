require "rails_helper"

describe "Poll Votation Type" do
  let(:author) { create(:user, :level_two) }

  before do
    login_as(author)
  end

  scenario "Unique answer" do
    question = create(:poll_question_unique, :with_answers, with_answers_count: 2)

    visit poll_path(question.poll)

    expect(page).to have_content "You can select a maximum of 1 answer."
    expect(page).to have_content(question.title)
    expect(page).to have_button("Vote Answer A")
    expect(page).to have_button("Vote Answer B")

    within "#poll_question_#{question.id}_answers" do
      click_button "Answer A"

      expect(page).to have_selector("span.answered", text: "Answer A")
      expect(page).not_to have_button("Answer A")

      click_button "Answer B"

      expect(page).to have_selector("span.answered", text: "Answer B")
      expect(page).to have_button("Answer A")
      expect(page).not_to have_button("Answer B")
    end
  end

  scenario "Multiple answers" do
    question = create(:poll_question_multiple, :with_answers, with_answers_count: 3, max_votes: 2)
    visit poll_path(question.poll)

    expect(page).to have_content "You can select a maximum of 2 answers."
    expect(page).to have_content(question.title)
    expect(page).to have_button("Vote Answer A")
    expect(page).to have_button("Vote Answer B")
    expect(page).to have_button("Vote Answer C")

    within "#poll_question_#{question.id}_answers" do
      click_button "Vote Answer A"

      expect(page).to have_button("You have voted Answer A")

      click_button "Vote Answer C"

      expect(page).to have_button("You have voted Answer C")
      expect(page).to have_button("Vote Answer B")

      click_button "You have voted Answer A"

      expect(page).to have_button("Vote Answer A")

      click_button "You have voted Answer C"

      expect(page).to have_button("Vote Answer C")

      click_button "Vote Answer B"

      expect(page).to have_button("You have voted Answer B")
      expect(page).to have_button("Vote Answer A")
      expect(page).to have_button("Vote Answer C")
    end
  end

  scenario "Prioritized answers" do
    question = create(:poll_question_prioritized, :with_answers, with_answers_count: 4)
    visit poll_path(question.poll)

    question_help = "You can select a maximum of 3 answers. You can drag and drop to reorder the answers."
    expect(page).to have_content(question_help)
    expect(page).to have_content(question.title)
    expect(page).to have_button("Vote Answer A")
    expect(page).to have_button("Vote Answer B")
    expect(page).to have_button("Vote Answer C")
    expect(page).to have_button("Vote Answer D")

    within("#poll_question_#{question.id}_answers") do
      click_button "Vote Answer D"

      expect(page).to have_button("You have voted Answer D")

      click_button "Vote Answer C"

      expect(page).to have_button("You have voted Answer C")

      click_button "Vote Answer A"

      expect(page).to have_button("You have voted Answer A")
    end

    within "ol" do
      expect("Answer D").to appear_before("Answer C")
      expect("Answer C").to appear_before("Answer A")
      expect(page).to have_selector("li[data-answer-id=\"Answer D\"]")
      expect(page).to have_selector("li[data-answer-id=\"Answer C\"]")
      expect(page).to have_selector("li[data-answer-id=\"Answer A\"]")
      expect(page).not_to have_selector("li[data-answer-id=\"Answer B\"]")
    end

    within("#poll_question_#{question.id}_answers") do
      click_button "You have voted Answer A"

      expect(page).to have_button("Vote Answer A")

      click_button "You have voted Answer C"

      expect(page).to have_button("Vote Answer C")

      click_button "You have voted Answer D"

      expect(page).to have_button("Vote Answer D")
    end

    expect(page).not_to have_selector(".ui-sortable")

    within("#poll_question_#{question.id}_answers") do
      click_button "Vote Answer B"

      expect(page).to have_button("You have voted Answer B")

      click_button "Vote Answer A"

      expect(page).to have_button("You have voted Answer A")
    end

    within "ol" do
      expect(page).to have_selector("li[data-answer-id=\"Answer B\"]:first-child")
      expect(page).to have_selector("li[data-answer-id=\"Answer A\"]:last-child")

      find("li", text: "Answer A").drag_to(find("li", text: "Answer B"))

      expect(page).to have_selector("li[data-answer-id=\"Answer A\"]:first-child")
      expect(page).to have_selector("li[data-answer-id=\"Answer B\"]:last-child")
    end

    click_button "Reorder list. Move answer \"Answer A\" down."

    within "ol" do
      expect(page).to have_selector("li[data-answer-id=\"Answer B\"]:first-child")
      expect(page).to have_selector("li[data-answer-id=\"Answer A\"]:last-child")
    end

    click_button "Reorder list. Move answer \"Answer A\" up."

    within "ol" do
      expect(page).to have_selector("li[data-answer-id=\"Answer A\"]:first-child")
      expect(page).to have_selector("li[data-answer-id=\"Answer B\"]:last-child")
    end
  end
end
