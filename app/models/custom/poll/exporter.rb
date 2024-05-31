class Poll::Exporter
    require "csv"
    require 'date'

    def initialize(poll_answers = [])
      @answers = poll_answers
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << headers
        @answers.each { |answer| csv << csv_values(answer) }
      end
    end

    private

      def headers
        [
          I18n.t("admin.polls.results.export_list.id"),
          I18n.t("admin.polls.results.export_list.question_id"),
          I18n.t("admin.polls.results.export_list.answer"),
          I18n.t("admin.polls.results.export_list.author_id")
        ]
      end

      def csv_values(answer)
        if answer.question.vote_type == 'info_birthdate'
          answer_text = calculate_age(answer.answer.to_date)
        else
          answer_text = answer.answer
        end
        [
          answer.id.to_s,
          answer.question_id.to_s,
          answer_text,
          answer.author_id.to_s
        ]
      end

      def calculate_age(dob)
        now = Time.now.utc.to_date
        now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
      end
  end
