class EdoLogger < ActiveSupport::Logger

  @@actions_no_auditables = %w[ show index new share edit ]

  def initialize(*args)
    super
    @formatter = formatter
  end

  def formatter
    Proc.new{ |severity, time, progname, msg|
      unless msg.nil?
        type = progname
        if progname.nil?
          type = "SYSTEM"
        end

        formatted_severity = sprintf("%-5s",severity.to_s)
        formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
        "#{formatted_time}::#{formatted_severity.strip}::#{$$} :: #{type} :: #{msg.to_s.strip}\n"
      end
    }
  end

  def self.audit(user, params, has_errors, errors)
    message = {}

    controller    = nil
    action        = nil
    other_params  = nil
    audit_info    = nil

    unless params.nil?
      controller = params[:controller]
      action = params[:action]
      audit_info = params[:audit_info]
      other_params = self.except_nested(params.except(:controller, :action, :utf8, :authenticity_token, :commit, :audit_info), "password")
    end

    if !controller.nil? && !action.nil? && !@@actions_no_auditables.include?(action)
      message = self.concat_to_message(message, "info", audit_info) unless audit_info.nil?
      message = self.concat_to_message(message, "user", user.email) unless user.nil?
      message = self.concat_to_message(message, "controller", controller) unless controller.nil?
      message = self.concat_to_message(message, "action", action) unless action.nil?
      message = self.concat_to_message(message, "has_errors", has_errors) if has_errors
      message = self.concat_to_message(message, "errors", errors) if has_errors && !errors.nil?
      message = self.concat_to_message(message, "params", other_params) unless other_params.nil?

      message
    end
  end

  def self.concat_to_message(full_message, field_name, message)
    full_message[field_name] = message

    full_message
  end

  private
    def self.except_nested(x,key)
      case x
      when Hash then x = x.inject({}) {|m, (k, v)| m[k] = except_nested(v,key) unless k == key ; m }
      when Array then x.map! {|e| except_nested(e,key)}
      end
      x
    end
end
