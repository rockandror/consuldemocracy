class AdvancedSearchComponent < ApplicationComponent
  attr_reader :search_path
  delegate :options_for_select, :setting, to: :helpers

  def initialize(search_path:, terms:)
    @search_path = search_path
    @terms = terms
  end

  private

    def display_advanced_search
      "display: none;" if @terms.blank?
    end

    def display_date_range
      "display: none;" unless custom_date_range?
    end

    def official_level_search_options
      options_for_select((1..5).map { |i| [setting["official_level_#{i}_name"], i] },
                         params[:advanced_search].try(:[], :official_level))
    end

    def date_range_options
      options_for_select([
        [t("shared.advanced_search.date_1"), 1],
        [t("shared.advanced_search.date_2"), 2],
        [t("shared.advanced_search.date_3"), 3],
        [t("shared.advanced_search.date_4"), 4],
        [t("shared.advanced_search.date_5"), "custom"]],
        selected_date_range)
    end

    def selected_date_range
      custom_date_range? ? "custom" : params[:advanced_search].try(:[], :date_min)
    end

    def custom_date_range?
      params[:advanced_search].try(:[], :date_max).present?
    end
end
