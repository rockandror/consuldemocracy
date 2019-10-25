class Verification::Handler
  include ActiveModel::Model

  attr_accessor :response, :user
  delegate :success, to: :response, allow_nil: true
  alias :success? :success

  def initialize(attributes = {})
    define_verification_fields
    define_confirmation_fields

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

    def define_verification_fields
      Verification::Configuration.verification_fields(self.class.id).pluck(:name).each do |attr|
        define_singleton_method attr do
          instance_variable_get "@#{attr}"
        end

        define_singleton_method "#{attr}=" do |arg|
          instance_variable_set "@#{attr}", arg
        end
      end
    end

    def define_confirmation_fields
      Verification::Configuration.confirmation_fields.each do |confirmation_field|
        define_singleton_method confirmation_field do
          instance_variable_get "@#{confirmation_field}"
        end

        define_singleton_method "#{confirmation_field}=" do |arg|
          instance_variable_set "@#{confirmation_field}", arg
        end
      end
    end

    def successful_response(attributes)
      message = I18n.t("verification.handlers.#{self.class.id}.verify.success")

      Verification::Handlers::Response.new true, message, attributes, nil
    end

    def error_response(attributes)
      message = I18n.t("verification.handlers.#{self.class.id}.verify.error")

      Verification::Handlers::Response.new false, message, attributes, nil
    end

    def get_geozone(census_code)
      Geozone.find_by(census_code: census_code)
    end

    def field_respresent_geozone
      field_assignments_to_match.joins(:verification_field).
        where("verification_fields.represent_geozone": true)
    end

    def is_age_verifcation_required?
      field_represent_min_age_to_participate.any?
    end

    def field_represent_min_age_to_participate
      field_assignments_to_match.joins(:verification_field).
        where("verification_fields.represent_min_age_to_participate": true)
    end
end

dir = Rails.root.join("app", "models", "verification", "handlers", "*.rb")
Dir[dir].each { |file| require_dependency file }
