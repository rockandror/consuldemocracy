require "rails_helper"

describe Admin::Poll::Questions::Answers::VideosController, :admin do
  let(:started_poll) { create(:poll) }
  let(:question_from_started_poll) { create(:poll_question, poll: started_poll) }
  let(:answer_from_started_poll) { create(:poll_question_answer, question: question_from_started_poll) }
  let(:video_from_started_poll) { create(:poll_answer_video, answer: answer_from_started_poll) }

  let(:future_poll) { create(:poll, starts_at: 1.day.from_now) }
  let(:question_from_future_poll) { create(:poll_question, poll: future_poll) }
  let(:answer_from_future_poll) { create(:poll_question_answer, question: question_from_future_poll) }
  let(:video_from_future_poll) { create(:poll_answer_video, answer: answer_from_future_poll) }

  describe "POST create" do
    it "Is not possible for an already started poll" do
      post :create, params: {
        poll_question_answer_video: {
         title: "Video from started poll",
         url: "https://www.youtube.com/watch?v=-JMf43st-1A",
         answer_id: answer_from_started_poll
        },
        answer_id: answer_from_started_poll
      }

      expect(flash[:alert]).to eq "It is not possible to create videos for an already started poll."
      expect(response).to redirect_to admin_answer_videos_path(answer_from_started_poll)
      expect(Poll::Question::Answer::Video.count).to eq 0
    end

    it "Is possible for a not started poll" do
      post :create, params: {
        poll_question_answer_video: {
         title: "Video from not started poll",
         url: "https://www.youtube.com/watch?v=-JMf43st-1A",
         answer_id: answer_from_future_poll
        },
        answer_id: answer_from_future_poll
      }

      expect(flash[:notice]).to eq "Video created successfully"
      expect(response).to redirect_to admin_answer_videos_path(answer_from_future_poll)
      expect(Poll::Question::Answer::Video.count).to eq 1
    end
  end

  describe "GET Edit" do
    it "Is not possible for an already started poll" do
      get :edit, params: { id: video_from_started_poll }

      expect(flash[:alert]).to eq "It is not possible to modify videos for an already started poll."
      expect(response).to redirect_to admin_answer_videos_path(answer_from_started_poll)
    end

    it "Is possible for a not started poll" do
      get :edit, params: { id: video_from_future_poll }

      expect(flash[:alert]).to be_nil
      expect(response).not_to be_redirect
    end
  end

  describe "PATCH update" do
    it "Is not possible for an already started poll" do
      patch :update, params: {
        poll_question_answer_video: {
          answer_id: answer_from_started_poll,
          title: "New title",
          url: video_from_started_poll.url
        },
        id: video_from_started_poll
      }

      response_alert = response.request.flash[:alert]
      expect(response_alert).to eq "It is not possible to modify videos for an already started poll."
      expect(response).to redirect_to admin_answer_videos_path(answer_from_started_poll)
      expect(video_from_started_poll.reload.title).not_to eq "New title"
      expect(video_from_started_poll.reload.title).to eq "Sample video title"
    end

    it "Is possible for a not started poll" do
      patch :update, params: {
        poll_question_answer_video: {
          answer_id: answer_from_future_poll,
          title: "New title",
          url: video_from_future_poll.url
        },
        id: video_from_future_poll
      }

      expect(flash[:notice]).to eq "Changes saved"
      expect(video_from_future_poll.reload.title).to eq "New title"
    end
  end

  describe "DELETE destroy" do
    it "Is not possible for an already started poll" do
      delete :destroy, params: { id: video_from_started_poll }

      expect(flash[:alert]).to eq "It is not possible to delete videos for an already started poll."
      expect(response).to redirect_to admin_answer_videos_path(answer_from_started_poll)
      expect(Poll::Question::Answer::Video.count).to eq 1
    end

    it "Is possible for a not started poll" do
      delete :destroy, params: { id: video_from_future_poll }

      expect(flash[:notice]).to eq "Answer video deleted successfully."
      expect(Poll::Question::Answer::Video.count).to eq 0
    end
  end
end
