module Flaggable
  extend ActiveSupport::Concern

  included do
    has_many :flags, as: :flaggable
    scope :all_records, -> { where("flags_count >= 0") }
    scope :no_flags, -> { where("flags_count = 0").where(ignored_flag_at: nil, hidden_at: nil) }
    scope :no_flags_proposals, -> { where("flags_count = 0 AND published_at IS NOT NULL").where(ignored_flag_at: nil, hidden_at: nil) }
    scope :flagged, -> { where("flags_count > 0") }
    scope :pending_flag_review, -> { flagged.where(ignored_flag_at: nil, hidden_at: nil) }
    scope :with_ignored_flag, -> { where.not(ignored_flag_at: nil).where(hidden_at: nil) }
    scope :with_confirmed_hide_at, -> {all_records.with_deleted.where.not(hidden_at: nil)} 
  end

  def ignored_flag?
    ignored_flag_at.present?
  end

  def ignore_flag
    update(ignored_flag_at: Time.current)
  end

end
