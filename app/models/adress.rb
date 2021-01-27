class Adress < ApplicationRecord
    has_many :users

    #validates :road_type, :road_name, :road_number, :postal_code, :district, :borought
    validates :postal_code, format: { with: /\d{5}/ }
end
