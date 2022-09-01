require "rails_helper"

describe Poll::Question::Answer do
  it_behaves_like "globalizable", :poll_question_answer

  describe "#with_content" do
    it "returns answers with a description" do
      answer = create(:poll_question_answer, description: "I've got a description")

      expect(Poll::Question::Answer.with_content).to eq [answer]
    end

    it "returns answers with images and no description" do
      answer = create(:poll_question_answer, :with_image, description: "")

      expect(Poll::Question::Answer.with_content).to eq [answer]
    end

    it "returns answers with documents and no description" do
      question = create(:poll_question_answer, :with_document, description: "")

      expect(Poll::Question::Answer.with_content).to eq [question]
    end

    it "returns answers with videos and no description" do
      question = create(:poll_question_answer, :with_video, description: "")

      expect(Poll::Question::Answer.with_content).to eq [question]
    end

    it "does not return answers with no description and no images, documents nor videos" do
      create(:poll_question_answer, description: "")

      expect(Poll::Question::Answer.with_content).to be_empty
    end
  end

  describe "#with_read_more?" do
    it "returns false when the answer does not have description, images, videos nor documents" do
      poll_question_answer = build(:poll_question_answer, description: nil)

      expect(poll_question_answer.with_read_more?).to be_falsy
    end

    it "returns true when the answer has description, images, videos or documents" do
      poll_question_answer = build(:poll_question_answer, description: "Answer description")

      expect(poll_question_answer.with_read_more?).to be_truthy

      poll_question_answer = build(:poll_question_answer, :with_image)

      expect(poll_question_answer.with_read_more?).to be_truthy

      poll_question_answer = build(:poll_question_answer, :with_document)

      expect(poll_question_answer.with_read_more?).to be_truthy

      poll_question_answer = build(:poll_question_answer, :with_video)

      expect(poll_question_answer.with_read_more?).to be_truthy
    end
  end

  describe "#total_votes" do
    it "when question is unique returns the existing answers count" do
      question = create(:poll_question_unique)
      answer_yes = create(:poll_question_answer, question: question, title: "Yes")
      answer_no = create(:poll_question_answer, question: question, title: "No")
      create_list(:poll_answer, 2, question: question, answer: "Yes")
      create_list(:poll_answer, 4, question: question, answer: "No")

      expect(answer_yes.total_votes).to eq(2)
      expect(answer_no.total_votes).to eq(4)
    end

    it "when question is multiple returns the existing answers count" do
      question = create(:poll_question_multiple, :with_answers, with_answers_count: 4, max_votes: 2)
      answer_a, answer_b, answer_c, answer_d = question.question_answers.order(:id)
      user_1 = create(:user)
      create(:poll_answer, question: question, answer: "Answer A", author: user_1)
      create(:poll_answer, question: question, answer: "Answer B", author: user_1)
      user_2 = create(:user)
      create(:poll_answer, question: question, answer: "Answer B", author: user_2)
      create(:poll_answer, question: question, answer: "Answer C", author: user_2)
      user_3 = create(:user)
      create(:poll_answer, question: question, answer: "Answer C", author: user_3)
      create(:poll_answer, question: question, answer: "Answer D", author: user_3)

      expect(answer_a.total_votes).to eq(1)
      expect(answer_b.total_votes).to eq(2)
      expect(answer_c.total_votes).to eq(2)
      expect(answer_d.total_votes).to eq(1)
    end

    it "when question is prioritized returns the sum of answers values" do
      question = create(:poll_question_prioritized, :with_answers, with_answers_count: 4, max_votes: 2)
      answer_a, answer_b, answer_c, answer_d = question.question_answers.order(:id)
      user_1 = create(:user)
      create(:poll_answer, question: question, answer: "Answer A", author: user_1, order: 1)
      create(:poll_answer, question: question, answer: "Answer B", author: user_1, order: 2)
      user_2 = create(:user)
      create(:poll_answer, question: question, answer: "Answer B", author: user_2, order: 1)
      create(:poll_answer, question: question, answer: "Answer C", author: user_2, order: 2)
      user_3 = create(:user)
      create(:poll_answer, question: question, answer: "Answer C", author: user_3, order: 1)
      create(:poll_answer, question: question, answer: "Answer D", author: user_3, order: 2)

      expect(answer_a.total_votes).to eq(2)
      expect(answer_b.total_votes).to eq(3)
      expect(answer_c.total_votes).to eq(3)
      expect(answer_d.total_votes).to eq(1)
    end
  end
end
