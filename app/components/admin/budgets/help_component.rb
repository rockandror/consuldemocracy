class Admin::Budgets::HelpComponent < ApplicationComponent
  attr_reader :i18n_namespace, :mode

  def initialize(i18n_namespace, mode: nil)
    @i18n_namespace = i18n_namespace
    @mode = mode
  end

  private

    def text
      if i18n_namespace == "budgets"
        t("admin.#{i18n_namespace}.index.help_block")
      elsif mode == "single"
        t("admin.#{i18n_namespace}.index.single.help_block")
      else
        t("admin.#{i18n_namespace}.index.multiple.help_block")
      end
    end
end
