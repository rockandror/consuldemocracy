class WebSection < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :banners, through: :sections
end
