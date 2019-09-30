module Flaggable
  extend ActiveSupport::Concern

  included do
    has_many :flags, as: :flaggable
    scope :flagged, -> { where("flags_count > 0") }
    scope :pending_flag_review, -> { flagged.where(ignored_flag_at: nil, hidden_at: nil) }
    scope :with_ignored_flag, -> { flagged.where.not(ignored_flag_at: nil).where(hidden_at: nil) }
    scope :with_confirmed_hide_at, -> {flagged.where.not(confirmed_hide_at: nil, hidden_at: nil)}
  end

  def ignored_flag?
    ignored_flag_at.present?
  end

  def ignore_flag
    puts "========================="
    puts "ignore_flag"
    xx
    update(ignored_flag_at: Time.current)
  end

end
