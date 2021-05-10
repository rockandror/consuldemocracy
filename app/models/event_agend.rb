class EventAgend < ApplicationRecord
    validates :date_at, :hour_at, presence: true
    validate :compare_hours

    self.table_name = "event_agends"

    def hour
        if self.hour_to.blank?
            I18n.t('admin.event_agends.time_one', hour: self.hour_at)
        else
            I18n.t('admin.event_agends.time_other', hour_at: self.hour_at, hour_to: self.hour_to)
        end
    rescue
        ""
    end

    private 

    def compare_hours
        if !self.hour_at.blank? && !self.hour_to.blank? && self.hour_at > self.hour_to
            self.errors.add(:hour_to, I18n.t('admin.event_agends.error_compare'))
        end
    end
end