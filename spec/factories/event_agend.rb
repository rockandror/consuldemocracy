FactoryBot.define do
    factory :event_agend do
        date_at Time.zone.now
        hour_at "08:00"
        hour_to "20:00"
    end
end