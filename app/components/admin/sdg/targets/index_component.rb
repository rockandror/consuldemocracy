class Admin::SDG::Targets::IndexComponent < ApplicationComponent
  attr_reader :targets

  def initialize(targets)
    @targets = targets
  end

  private

    def title
      t("admin.sdg.targets.index.title")
    end

    def attribute_name(attribute)
      SDG::Target.human_attribute_name(attribute)
    end
end
