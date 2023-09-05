class Admin::Audits::RowComponent < ApplicationComponent
  with_collection_parameter :audit
  attr_reader :audit

  delegate :field_name, :audit_value, :new_value, :old_value, to: :helpers

  def initialize(audit:)
    @audit = audit
  end
end
