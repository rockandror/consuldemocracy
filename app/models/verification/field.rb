class Verification::Field < ApplicationRecord
  self.table_name = "verification_fields"

  serialize :handlers

  translates :label, touch: true
  include Globalizable

  validates_translation :label, presence: true, length: { minimum: 2 }
  validates :name, presence: true
  validates :label, presence: true
  validates :position, presence: true
  validate  :handlers_exists, if: -> { handlers.present? }

  def handlers=(handlers)
    handlers = handlers.split(",") if handlers.is_a?(String)
    handlers = [handlers]          if handlers.is_a?(Symbol)
    super(handlers)
  end

  private

    def handlers_exists
      if handlers.any?{|handler| !handler_exists?(handler)}
        errors.add(:handlers, :handler_does_not_exists)
      end
    end

    def handler_exists?(handler)
      Verification::Configuration.ids.include?(handler.to_s)
    end
end
