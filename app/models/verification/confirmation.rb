class Verification::Confirmation
  include ActiveModel::Model
  attr_accessor :confirmation_fields, :user

  validates :user, presence: true
  validate :confirmations, if: :confirmation_codes_present?

  def initialize(attributes = {})
    @confirmation_fields = define_confirmation_fields
    define_fields_validations

    super
  end

  def save
    return false unless valid?

    user.last_verification_process.mark_as_verified
    user.last_verification_process.mark_as_phone_verified if sms_confirmation_code.present?
    user.last_verification_process.mark_as_confirmed
  end

  private

    def load_confirmation_fields
      Verification::Configuration.confirmation_fields
    end

    def define_confirmation_fields
      load_confirmation_fields.each_with_object([]) do |confirmation_field, confirmation_fields|
        define_singleton_method confirmation_field do
          instance_variable_get "@#{confirmation_field}"
        end

        define_singleton_method "#{confirmation_field}=" do |arg|
          instance_variable_set "@#{confirmation_field}", arg
        end

        confirmation_fields << confirmation_field
      end
    end

    def confirmation_codes_present?
      @confirmation_fields.all? { |confirmation_field| send(confirmation_field).present? }
    end

    def confirmations
      Verification::Configuration.required_confirmation_handlers.each do |id, handler|
        handler_instance = handler.new

        response = handler_instance.confirm(fields_for_handler)
        unless response.success?
          errors.add "#{handler.id.downcase.underscore}_confirmation_code", response.message
        end
      end
    end

    def fields_for_handler
      params = {}
      @confirmation_fields.each do |confirmation_field|
        params[confirmation_field] = send(confirmation_field)
      end
      params[:user] = user
      params.symbolize_keys!
    end

    def define_fields_validations
      define_presence_validations
    end

    def define_presence_validations
      @confirmation_fields.each do |confirmation_field|
        self.singleton_class.class_eval do
          validates confirmation_field, presence: true
        end
      end
    end
end
