class SiteCustomization::CityMap
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :address, :latitude, :longitude, :zoom

  validates_presence_of :address, :latitude, :longitude, :zoom

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if self.valid?
      Setting['feature.map.address'] = @address
      Setting['feature.map.latitude'] = @latitude
      Setting['feature.map.longitude'] = @longitude
      Setting['feature.map.zoom'] = @zoom
      return true
    end
    return false
  end

  def self.find
    SiteCustomization::CityMap.new(address:    Setting['feature.map.address'],
                                   latitude:   Setting['feature.map.latitude'].to_f,
                                   longitude:  Setting['feature.map.longitude'].to_f,
                                   zoom:       Setting['feature.map.zoom'].to_i)
  end

  def persisted?
    false
  end

end
