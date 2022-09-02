require "rails_helper"

describe "Videos", :admin do
  let(:future_poll) { create(:poll, starts_at: 1.day.from_now) }
  let(:current_poll) { create(:poll) }
  let(:title) { "'Magical' by Junko Ohashi" }
  let(:url) { "https://www.youtube.com/watch?v=-JMf43st-1A" }
  let(:new_title) { "Sweet Love" }
  let(:new_url) { "https://www.youtube.com/watch?v=6C4VR81GDtM" }

  context "Create" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Video list"
      end

      click_link "Add video"

      fill_in "Title", with: title
      fill_in "External video", with: url

      click_button "Save"

      expect(page).to have_content "Video created successfully"
      expect(page).to have_content title
      expect(page).to have_content url
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Video list"
      end

      click_link "Add video"

      fill_in "Title", with: title
      fill_in "External video", with: url

      click_button "Save"

      expect(page).to have_content "It is not possible to create videos for an already started poll."
      expect(page).not_to have_content title
      expect(page).not_to have_content url
    end
  end

  context "Update" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      visit edit_admin_video_path(video)

      fill_in "Title", with: new_title
      fill_in "External video", with: new_url

      click_button "Save"

      expect(page).to have_content "Changes saved"
      expect(page).to have_content new_title
      expect(page).to have_content new_url
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      visit edit_admin_video_path(video)

      expect(page).to have_content "It is not possible to modify videos for an already started poll."
      expect(page).to have_current_path(admin_answer_videos_path(answer))
    end
  end

  context "Destroy" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      visit admin_answer_videos_path(answer)

      within("#poll_question_answer_video_#{video.id}") do
        accept_confirm("Are you sure? This action will delete \"#{title}\" and can't be undone.") do
          click_button "Delete"
        end
      end

      expect(page).to have_content "Answer video deleted successfully."
      expect(page).not_to have_content title
      expect(page).not_to have_content url
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      visit admin_answer_videos_path(answer)

      within("#poll_question_answer_video_#{video.id}") do
        accept_confirm { click_button "Delete" }
      end

      expect(page).to have_content "It is not possible to delete videos for an already started poll."
      expect(page).to have_content title
      expect(page).to have_content url
      expect(page).to have_current_path(admin_answer_videos_path(answer))
    end
  end
end
