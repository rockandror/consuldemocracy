class Admin::Audits::IndexComponent < ApplicationComponent
  attr_reader :audits

  delegate :truncate_audit_value, to: :helpers

  def initialize(audits:)
    @audits = audits
  end
end
