require 'geocoder'

class SiteCustomization::CityMap
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  include ActiveModel::Model

  extend Geocoder::Model::ActiveRecord
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  extend ActiveModel::Translation
  # define_model_callbacks :initialize, :only => :after

  attr_accessor :address, :latitude, :longitude, :zoom

  validates_presence_of :address, :latitude, :longitude, :zoom

  after_validation :geocode

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def attributes
    return @attributes if @attributes
    @attributes = {
      'address'   => address,
      'latitude'  => latitude,
      'longitude' => longitude,
      'zoom'      => zoom,
    }
  end

  def save
    if self.valid?
      Setting['feature.map.address'] = @address
      Setting['feature.map.latitude'] = @latitude
      Setting['feature.map.longitude'] = @longitude
      Setting['feature.map.zoom'] = @zoom
      return true
    end
    false
  end

  def self.find
    SiteCustomization::CityMap.new(address:    Setting['feature.map.address'],
                                   latitude:   Setting['feature.map.latitude'],
                                   longitude:  Setting['feature.map.longitude'],
                                   zoom:       Setting['feature.map.zoom'])
  end

  def geocode
    if @address.present? && not(default_location?)
      result = Geocoder.search(@address)
      if result.any?
        @latitude = result.first.data['lat']
        @longitude = result.first.data['lon']
      end
    end
  end

  def default_location?
    Setting['feature.map.address'].present? && Setting['feature.map.address'] == "Greenwich" &&
    Setting['feature.map.latitude'].present? && Setting['feature.map.latitude'] == "51.48" &&
    Setting['feature.map.longitude'].present? && Setting['feature.map.longitude'] == "0" &&
    Setting['feature.map.zoom'].present? && Setting['feature.map.zoom'] == "10"
  end

  def persisted?
    false
  end

end
