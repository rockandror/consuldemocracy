class Campaign < ApplicationRecord
  audited on: [:create, :update, :destroy]
end
