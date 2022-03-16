module ReportAttributes
  extend ActiveSupport::Concern

  private

    def report_attributes
      Report.kinds.map { |kind| :"#{kind}_enabled" }
    end
end
