class Verification::Handler
  include ActiveModel::Model

  attr_accessor :response, :user
  delegate :success, to: :response, allow_nil: true
  alias :success? :success

  def initialize(attributes = {})
    define_verification_form_fields
    define_confirmation_form_fields

    super
  end

  def verify(attributes = {})
    raise MissingMethodImplementation, "You must implement the verify method!"
  end

  def confirm(attributes = {})
    if self.class.requires_confirmation?
      raise MissingMethodImplementation, "You must implement the confirm method!"
    end
  end

  class << self
    attr_reader :id

    def register_as(id = nil)
      @id = id.to_s
    end

    def requires_confirmation(value = true)
      @requires_confirmation = value
    end

    def requires_confirmation?
      @requires_confirmation == true
    end
  end

  class MissingMethodImplementation < Exception; end

  private

    def verification_form_fields
      Verification::Field.all.select { |f| f.handlers.include?(self.class.id.to_s) }
    end

    def define_verification_form_fields
      verification_form_fields.pluck(:name).each do |attr|

        define_singleton_method attr do
          instance_variable_get "@#{attr}"
        end

        define_singleton_method "#{attr}=" do |arg|
          instance_variable_set "@#{attr}", arg
        end
      end
    end

    def define_confirmation_form_fields
      Verification::Configuration.confirmation_fields.each do |confirmation_field|
        define_singleton_method confirmation_field do
          instance_variable_get "@#{confirmation_field}"
        end

        define_singleton_method "#{confirmation_field}=" do |arg|
          instance_variable_set "@#{confirmation_field}", arg
        end
      end
    end
end

dir = Rails.root.join("app", "models", "verification", "handlers", "*.rb")
Dir[dir].each { |file| require_dependency file }
