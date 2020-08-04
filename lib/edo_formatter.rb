class EdoFormatter < LogStashLogger::Formatter::JsonLines
  def call(severity, time, progname, message)
    @progname = progname
    super
  end

  private

    def build_event(message, severity, time)
      event = super
      event[:type] = @progname
      event
    end

    def format_event(event)
      "#{event.to_json}\n"
    end
end
