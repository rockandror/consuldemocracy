class Verification::Handler::FieldAssignment < ApplicationRecord
  self.table_name = "verification_handler_field_assignments"
  belongs_to :verification_field, class_name: "Verification::Field"

  validates :verification_field_id, presence: true
  validates :handler, presence: true
  validates :verification_field_id, uniqueness: { scope: :handler }
  validate :sms_handler
  validate :format_iso_8601, if: -> { format.present? && verification_field.date? }

  scope :by_handler, -> (handler) { where(handler: handler) }
  scope :with_response_path, -> { where.not(response_path: [nil, ""]) }

  private

    def sms_handler
      return unless handler == "sms"

      unless verification_field.name == "phone"
        errors.add :verification_field_id, :only_phone_allowed
      end
    end

    def format_iso_8601
      date = Date.current

      string_date = date.strftime(format)
      begin
        Date.parse(string_date)
      rescue ArgumentError
        errors.add :format, :invalid
      end
    end
end
