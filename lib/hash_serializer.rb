class HashSerializer
  def self.dump(content)
    parse_for(content)
  end

  def self.load(content)
    parse_for(content)
  end

  def self.parse_for(content)
    return {} if content.nil?

    if content.is_a? Hash
      content
    elsif content.is_a? String
      content.empty? ? {} : JSON.parse(content.gsub("=>", ":"))
    else
      content.as_json
    end

  rescue JSON::ParserError
    content
  end
end
