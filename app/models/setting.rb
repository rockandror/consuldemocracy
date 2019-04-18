class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  default_scope { order(id: :asc) }

  def type
    prefix = key.split(".").first
    if %w[feature process map html homepage remote_census_general remote_census_request remote_census_response].include? prefix
      prefix
    else
      "configuration"
    end
  end

  def enabled?
    value.present?
  end

  # def self.calculate_presence_date_of_birth?
  #   Setting["feature.remote_census"].present? && Setting["remote_census_request.alias_date_of_birth"].present?
  # end
  #
  # def self.calculate_presence_postal_code?
  #   Setting["feature.remote_census"].present? && Setting["remote_census_request.alias_postal_code"].present?
  # end

  class << self
    def [](key)
      where(key: key).pluck(:value).first.presence
    end

    def []=(key, value)
      setting = where(key: key).first || new(key: key)
      setting.value = value.presence
      setting.save!
      value
    end

    def rename_key(from:, to:)
      if where(key: to).empty?
        value = where(key: from).pluck(:value).first.presence
        create!(key: to, value: value)
      end
      remove(from)
    end

    def remove(key)
      setting = where(key: key).first
      setting.destroy if setting.present?
    end
  end
end
