class Legislation::Answers::Exporter
  require "csv"

  def initialize(process)
    @process = process
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @process.questions.each do |question|
        question.comments.each { |comment| csv << csv_values(question, comment) }
        answers = get_answers(question)
        answers.each { |answer| csv << answers_csv_values(answer) }
      end
    end
  end

  private

    def get_answers(question)
      Legislation::Answer.where(question: question)
    end

    def headers
      [
        I18n.t("admin.legislation.answers.export_list.id"),
        I18n.t("admin.legislation.answers.export_list.type"),
        I18n.t("admin.legislation.answers.export_list.legislation_question_id"),
        I18n.t("admin.legislation.answers.export_list.legislation_question_text"),
        I18n.t("admin.legislation.answers.export_list.legislation_question_comment_text"),
        I18n.t("admin.legislation.answers.export_list.author_id"),
        I18n.t("admin.legislation.answers.export_list.author_date_of_birth"),
        I18n.t("admin.legislation.answers.export_list.author_location"),
        I18n.t("admin.legislation.answers.export_list.author_gender")
      ]
    end

    def answers_csv_values(answer)
      [
        answer.id,
        "Opcional",
        answer.question.id,
        answer.question.title,
        answer.question_option.value,
        answer.user.id,
        answer.user.date_of_birth,
        get_location(answer.user.location),
        get_gender(answer.user.gender)
      ]
    end

    def csv_values(question, comment)
      [
        comment.id.to_s,
        "Libre",
        question.id,
        question.title,
        comment.body,
        comment.user.id,
        answer.user.date_of_birth,
        get_location(answer.user.location),
        get_gender(answer.user.gender)
      ]
    end

    def get_gender(gender_key)
      if gender_key
        return I18n.t("activemodel.models.user.gender.#{gender_key}")
      else
        return ""
      end
    end

    def get_location(location_key)
      if location_key
        return I18n.t("activemodel.models.user.locations.values.#{location_key}")
      else
        return ""
      end
    end
end
