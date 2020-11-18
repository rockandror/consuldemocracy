module SDG::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :sdg_relations, as: :relatable, dependent: :destroy, class_name: "SDG::Relation"

    %w[Goal Target].each do |sdg_type|
      has_many :"sdg_#{sdg_type.tableize}",
               through: :sdg_relations,
               source: :related_sdg,
               source_type: "SDG::#{sdg_type}"
    end
  end

  def related_sdgs
    sdg_relations.map(&:related_sdg)
  end
end
