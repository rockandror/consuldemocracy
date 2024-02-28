class Legislation::Processes::Exporter
  require "csv"
  require "zip"

  def initialize(process)
    @process = process
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      csv << csv_values(@process)
    end
  end

  def to_zip
    filename = "process.zip"
    temp_file = Tempfile.new(filename)

    begin
      Zip::OutputStream.open(temp_file) { |zos| }

      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        zip.get_output_stream("process.csv") { |f| f.puts(to_csv) }
        zip.get_output_stream("questions_answers.csv") do |f|
          f.puts(Legislation::Answers::Exporter.new(@process).to_csv)
        end
        zip.get_output_stream("draft_comments.csv") do |f|
          f.puts(Legislation::Annotations::Exporter.new(@process).to_csv)
        end
        zip.get_output_stream("proposals.csv") do |f|
          f.puts(Legislation::Proposals::Exporter.new(@process).to_csv)
        end
      end

      File.read(temp_file.path)
    ensure # important steps below
      temp_file.close
      temp_file.unlink
    end
  end

  private

    def headers
      [
        I18n.t("admin.legislation.processes.export_list.id"),
        I18n.t("admin.legislation.processes.export_list.start_date"),
        I18n.t("admin.legislation.processes.export_list.end_date"),
        I18n.t("admin.legislation.processes.export_list.debate_start_date"),
        I18n.t("admin.legislation.processes.export_list.debate_end_date"),
        I18n.t("admin.legislation.processes.export_list.draft_publication_date"),
        I18n.t("admin.legislation.processes.export_list.allegations_start_date"),
        I18n.t("admin.legislation.processes.export_list.allegations_end_date"),
        I18n.t("admin.legislation.processes.export_list.result_publication_date"),
        I18n.t("admin.legislation.processes.export_list.proposals_phase_start_date"),
        I18n.t("admin.legislation.processes.export_list.proposals_phase_end_date"),
        I18n.t("admin.legislation.processes.export_list.proposals_description")
      ]
    end

    def csv_values(process)
      [
        process.id.to_s,
        process.start_date,
        process.end_date,
        # proposal.author.username.to_s,
        process.debate_start_date,
        process.debate_end_date,
        process.draft_publication_date,
        process.allegations_start_date,
        process.allegations_end_date,
        process.result_publication_date,
        process.proposals_phase_start_date,
        process.proposals_phase_end_date,
        ActionView::Base.full_sanitizer.sanitize(process.proposals_description)
      ]
    end
end
