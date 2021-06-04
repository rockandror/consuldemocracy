class Admin::Budgets::HeadingModeComponent < ApplicationComponent
  private

    def namespace
      "admin.budgets.index.heading_mode"
    end

    def modes
      %w[single multiple]
    end
end
