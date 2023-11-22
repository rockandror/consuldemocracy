class Admin::Settings::TableComponent < ApplicationComponent
  attr_reader :settings, :setting_name, :tab
  delegate :dom_id, to: :helpers

  def initialize(settings:, setting_name:, tab: nil)
    @settings = settings
    @setting_name = setting_name
    @tab = tab
  end

  def key_header
    if setting_name == "feature"
      t("admin.settings.setting")
    elsif setting_name == "setting"
      t("admin.settings.setting_name")
    else
      t("admin.settings.#{setting_name}")
    end
  end

  def value_header
    if setting_name == "feature"
      t("admin.settings.index.features.enabled")
    else
      t("admin.settings.setting_value")
    end
  end

  def table_class
    "featured-settings-table" if settings.all?(&:feature?)
  end

  def column_class
    "small-6" unless settings.all?(&:feature?)
  end
end
