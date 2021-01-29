class Adress < ApplicationRecord
    has_many :users

    validates :postal_code, format: { with: /\d{5}/ }
    
end
