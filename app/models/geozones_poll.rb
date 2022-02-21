class GeozonesPoll < ApplicationRecord
  belongs_to :geozone
  belongs_to :poll

  audited on: [:create, :update, :destroy]
end
