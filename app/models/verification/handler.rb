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
    @response = if defined?(super)
                  super(attributes)
                else
                  build_response(attributes)
                end
  end

  def confirm(attributes = {})
    build_confirmation_response(attributes)
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

  private

    def build_response(attributes = {})
      Verification::Handlers::Response.new true, I18n.t("verification.handler.verification.success"), attributes, nil
    end

    def build_confirmation_response(attributes = {})
      Verification::Handlers::Response.new true, I18n.t("verification.handler.confirmation.success"), attributes, nil
    end

    def define_verification_form_fields
      Verification::Field.all.select { |f| f.handlers.include?(self.class.id.to_s) }.pluck(:name).each do |attr|
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
Dir[Rails.root.join("app/models/verification/handlers/*.rb")].each {|file| require_dependency file }
