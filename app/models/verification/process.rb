class Verification::Process < ApplicationRecord
  include ActiveModel::Dates

  self.table_name = "verification_processes"

  attr_accessor :fields, :handlers, :responses

  validates :user, presence: true
  validate :handlers_attributes, on: :create

  belongs_to :user
  has_many :verification_values, dependent: :destroy,
                                 class_name: "Verification::Value",
                                 foreign_key: :verification_process_id,
                                 inverse_of: :verification_process

  has_many :verification_fields, through: :verification_values,
                                 class_name: "Verification::Field"

  before_create :handlers_verification, if: -> (process) { process.errors.none? }
  after_create :store_verification_values
  after_create :mark_as_verified, unless: :requires_confirmation?
  after_create :mark_as_confirmed, unless: :requires_confirmation?
  after_create :mark_as_residence_verified, if: :is_residence_verification_active?
  after_find :add_attributes_from_verification_fields_definition
  after_find :load_attributes_from_verification_values

  def initialize(attributes = {})
    add_attributes_from_verification_fields_definition

    parse_date_fields(attributes)
    remove_date_fields_attibutes(attributes)

    super
  end

  def requires_confirmation?
    Verification::Handler.descendants.select { |k| @handlers.include?(k.id) }.
      any?(&:requires_confirmation?)
  end

  def confirmations_pending?
    requires_confirmation? && !confirmed?
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

  def mark_as_verified
    update(verified_at: Time.current)
  end

  def mark_as_phone_verified
    update(phone_verified_at: Time.current)
  end

  def mark_as_residence_verified
    update(residence_verified_at: Time.current)
  end

  def mark_as_confirmed
    update(confirmed_at: Time.current)
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
        throw :abort
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
      Verification::Field.all.find_each do |field|
        define_singleton_method field.name do
          instance_variable_get "@#{field.name}"
        end

        define_singleton_method "#{field.name}=" do |arg|
          instance_variable_set "@#{field.name}", arg
        end
        define_confirmation_fields_accessors(field) if field.confirmation_validation?
      end
    end

    def parse_date_fields(attributes)
      Verification::Field.where(kind: :date).find_each do |field|
        send("#{field.name}=", parse_date(field.name, attributes))
      end
    end

    def remove_date_fields_attibutes(attributes)
      Verification::Field.where(kind: :date).find_each do |field|
        attributes = remove_date("date_of_birth", attributes)
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
      Verification::Field.all.visible.order(:position).each_with_object({}) do |field, hash|
        hash[field.name] = field
      end
    end

    # Return {} of fields for given handler by handler name
    def fields_for_handler(handler)
      params = {}
      @fields.each do |field_name, field|
        next unless field.handlers&.include?(handler)

        value = send(field_name)
        value = convert_date_field(field, handler, value) if field.date?
        params[field_name] = value
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
        Verification::Field.required.where.not(kind: :checkbox).find_each do |field|
          validates field.name, presence: true
        end
      end
    end

    def define_confirmation_validations
      self.singleton_class.class_eval do
        Verification::Field.confirmation_validation.find_each do |field|
          validates field.name, confirmation: true
        end
      end
    end

    def define_format_validations
      self.singleton_class.class_eval do
        Verification::Field.with_format.find_each do |field|
          validates field.name, format: { with: Regexp.new(field.format) }
        end
      end
    end

    def define_checkbox_validations
      self.singleton_class.class_eval do
        Verification::Field.with_checkbox_required.find_each do |field|
          validates field.name, acceptance: true
        end
      end
    end

    def store_verification_values
      @fields.each_with_object([]) do |(name, field), objects|
        objects << Verification::Value.create(
          verification_field: field,
          verification_process: self,
          value: send(name))
      end
    end

    def is_residence_verification_active?
      ["remote_census", "residents"].any? { |handler| @handlers.include?(handler) }
    end

    def convert_date_field(field, handler, value)
      assignment = field.assignments.by_handler(handler).first

      if assignment.format.present?
        value.strftime(assignment.format)
      else
        value.strftime("%F")
      end
    end

    def load_attributes_from_verification_values
      verification_values.find_each do |verification_value|
        attribute = verification_value.verification_field.name
        send("#{attribute}=", verification_value.value)
      end
    end
end
