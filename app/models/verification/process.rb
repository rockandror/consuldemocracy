class Verification::Process
  include ActiveModel::Model
  attr_accessor :fields, :handlers, :responses, :user

  validates :user, presence: true
  validate :handlers_verification
  validate :required_fields

  def initialize(attributes = {})
    @responses = []
    @fields = {}
    @handlers = []

    define_fields_accessors
    handlers_to_verify
    fields_to_verify

    super
  end

  def save
    return false unless valid?
  end

  def requires_confirmation?
    @handlers.each do |handler_name|
      return true if Verification::Handler.descendants.select{|klass| klass.id == handler_name}.first.requires_confirmation?
    end

    return false
  end

  private

    def handlers_verification
      return if @handlers.none?

      @handlers.each do |handler|
        handler_instance = Verification::Configuration.available_handlers[handler.to_sym].new(fields_for_handler(handler))
        @responses << handler_instance.verify
      end

      @responses.each do |response|
        errors.add(:base, response.message) unless response.success?
      end
    end

    def required_fields
      Verification::Field.required.each do |field|
        errors.add(field.name, :blank) if send(field.name).blank?
      end
    end

    def define_fields_accessors
      Verification::Field.all.pluck(:name).each do |attr|
        define_singleton_method attr do
          instance_variable_get "@#{attr}"
        end

        define_singleton_method "#{attr}=" do |arg|
          instance_variable_set "@#{attr}", arg
        end
      end
    end

    def handlers_to_verify
      @handlers = Verification::Field.all.where.not(handlers: [nil, ""]).pluck(:handlers).flatten.uniq
    end

    def fields_to_verify
      Verification::Field.all.each do |field|
        @fields[field.name] = field
      end
      @fields
    end

    def fields_for_handler(handler)
      params = {}
      @fields.each do |field_name, field|
        params[field_name] = send(field_name) if field.handlers&.include?(handler)
      end
      params.symbolize_keys!
    end
end
