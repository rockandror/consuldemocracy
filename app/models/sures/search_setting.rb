class Sures::SearchSetting < ApplicationRecord

    scope :order_settings, -> { where(data_type: 'order')}
    scope :select_settings, -> { where(data_type: 'select')}
    scope :text_settings, -> { where(data_type: 'text')}
    scope :fulltext_settings, -> { where(data_type: 'fulltext')}
    scope :search_settings, -> { where("data_type not in ('order')")}

    self.table_name = "sures_search_settings"

    def self.fieldSuresAnotation
        [
            :proposal_title, :proposal_objective, :territorial_scope, :location_performance, :technical_visibility,
            :actions_taken, :status, :financig_performance, :check_anno, :check_multianno, :annos, :tracking, :other, :updated_at, :created_at
        ]
    end
end