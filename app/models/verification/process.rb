class Verification::Process < ApplicationRecord
  self.table_name = "verification_processes"

  attr_accessor :fields, :handlers, :responses

  validates :user, presence: true
  validate :handlers_attributes, on: :create
  validate :handlers_verification, on: :create

  belongs_to :user

  after_save :save_verification_values
  after_save :mark_as_verified, unless: :requires_confirmation?
  after_save :mark_as_confirmed, unless: :requires_confirmation?
  after_save :mark_as_residence_verified, if: :is_residence_verification_active?
  after_find :add_attributes_from_verification_fields_definition

  def initialize(attributes = {})
    add_attributes_from_verification_fields_definition

    super
  end

  def requires_confirmation?
    Verification::Handler.descendants.select { |k| @handlers.include?(k.id) }.
      any?(&:requires_confirmation?)
  end

  def confirmations_pending?
    requires_confirmation? && !confirmed?
  end

  def mark_as_verified
    update_column(:verified_at, Time.current)
  end

  def mark_as_phone_verified
    update_column(:phone_verified_at, Time.current)
  end

  def mark_as_residence_verified
    update_column(:residence_verified_at, Time.current)
  end

  def mark_as_confirmed
    update_column(:confirmed_at, Time.current)
  end

  def verified?
    verified_at.present?
  end

  def verified_phone?
    phone_verified_at.present?
  end

  def verified_residence?
    residence_verified_at.present?
  end

  def confirmed?
    confirmed_at.present?
  end

  private

    def add_attributes_from_verification_fields_definition
      define_fields_accessors
      define_fields_validations

      @responses = {}
      @fields = fields_by_name
      @handlers = Verification::Configuration.active_handlers
    end

    def handlers_verification
      @handlers.each do |handler|
        handler_class = Verification::Configuration.available_handlers[handler]
        handler_instance = handler_class.new

        @responses[handler] = handler_instance.verify(fields_for_handler(handler))
      end

      if @responses.values.select { |response| response.error? }.any?
        errors.add :base, @responses.values.select { |response| response.error? }.collect(&:message)
      end
    end

    # Validates each verification process attributes through defined handlers and copy errors
    # to process attributes
    def handlers_attributes
      return if @handlers.none?

      @handlers.each do |handler|
        handler_instance = Verification::Configuration.available_handlers[handler].
          new(fields_for_handler(handler))

        unless handler_instance.valid?
          handler_instance.errors.each do |field, error|
            errors.add field, error
          end
        end
      end
    end

    # Defines attribute accessors for all verification fields
    def define_fields_accessors
      Verification::Field.all.each do |field|
        define_singleton_method field.name do
          instance_variable_get "@#{field.name}"
        end

        define_singleton_method "#{field.name}=" do |arg|
          instance_variable_set "@#{field.name}", arg
        end
        define_confirmation_fields_accessors(field) if field.confirmation_validation?
      end
    end

    def define_confirmation_fields_accessors(field)
      define_singleton_method "#{field.name}_confirmation" do
        instance_variable_get "@#{field.name}_confirmation"
      end

      define_singleton_method "#{field.name}_confirmation=" do |arg|
        instance_variable_set "@#{field.name}_confirmation", arg
      end
    end

    # Return {} with fields by name
    def fields_by_name
      Verification::Field.all.order(:position).each_with_object({}) do |field, hash|
        hash[field.name] = field
      end
    end

    # Return {} of fields for given handler by handler name
    def fields_for_handler(handler)
      params = {}
      @fields.each do |field_name, field|
        params[field_name] = send(field_name) if field.handlers&.include?(handler)
      end
      params[:user] = user
      params.symbolize_keys!
    end

    # Define self validations from existing verification fields
    def define_fields_validations
      define_presence_validations
      define_confirmation_validations
      define_format_validations
      define_checkbox_validations
    end

    def define_presence_validations
      self.singleton_class.class_eval do
        Verification::Field.required.each do |field|
          validates field.name, presence: true
        end
      end
    end

    def define_confirmation_validations
      self.singleton_class.class_eval do
        Verification::Field.confirmation_validation.each do |field|
          validates field.name, confirmation: true
        end
      end
    end

    def define_format_validations
      self.singleton_class.class_eval do
        Verification::Field.with_format.each do |field|
          validates field.name, format: { with: Regexp.new(field.format) }
        end
      end
    end

    def define_checkbox_validations
      self.singleton_class.class_eval do
        Verification::Field.with_checkbox_required.each do |field|
          validates field.name, acceptance: true
        end
      end
    end

    def save_verification_values
      verification_values = []
      @fields.each_with_object(verification_values) do |(name, field), verification_values|
        verification_values << Verification::Value.create(
          verification_field: field,
          verification_process: self,
          value: send(name))
      end

      return true if verification_values.size == @fields.size && verification_values.all?(&:persisted?)

      verification_values.select(&:persisted?).map(&:destroy)
      false
    end

    def is_residence_verification_active?
      ["remote_census", "residents"].any? { |handler| @handlers.include?(handler) }
    end
end
