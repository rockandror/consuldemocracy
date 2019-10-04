FactoryBot.define do
  factory :local_census_record, class: "LocalCensusRecord" do
    sequence(:document_number) { |n| "DOC_NUMBER#{n}" }
    document_type { 1 }
    date_of_birth { Date.new(1970, 1, 31) }
    postal_code { "28002" }
  end
  factory :local_census_records_import, class: "LocalCensusRecords::Import" do
    file {
      path = %w[spec fixtures files local_census_records import valid.csv]
      Rack::Test::UploadedFile.new(Rails.root.join(*path))
    }
  end

  sequence(:document_number) { |n| "#{n.to_s.rjust(8, "0")}X" }

  factory :verification_residence, class: Verification::Residence do
    user
    document_number
    document_type    { "1" }
    date_of_birth    { Time.zone.local(1980, 12, 31).to_date }
    postal_code      { "28013" }
    terms_of_service { "1" }

    trait :invalid do
      postal_code { "28001" }
    end
  end

  factory :failed_census_call do
    user
    document_number
    document_type { 1 }
    date_of_birth { Date.new(1900, 1, 1) }
    postal_code { "28000" }
  end

  factory :verification_sms, class: Verification::Sms do
    phone { "699999999" }
  end

  factory :verification_letter, class: Verification::Letter do
    user
    email { "user@consul.dev" }
    password { "1234" }
    verification_code { "5555" }
  end

  factory :lock do
    user
    tries { 0 }
    locked_until { Time.current }
  end

  factory :verified_user do
    document_number
    document_type { "dni" }
  end

  factory :verification_document, class: Verification::Management::Document do
    document_number
    document_type { "1" }
    date_of_birth { Date.new(1980, 12, 31) }
    postal_code { "28013" }
  end

  factory :verification_field, class: Verification::Field do
    sequence(:name)     { |n| "field#{n}" }
    sequence(:label)     { |n| "Label for field #{n}" }
    sequence(:position) { |n| n  + 1 }
    required false

    trait :required do
      required true
    end
  end

  factory :verification_confirmation, class: Verification::Confirmation do
    user
    initialize_with { new(attributes) }
  end

  factory :verification_process, class: Verification::Process do
    user
    initialize_with { new(attributes) }
  end

  factory :verification_value, class: Verification::Value do
    sequence(:value)     { |n| "value#{n}" }
    user
    verification_field
  end

  factory :verification_resident, class: Verification::Resident do
    sequence(:data){|n| { email: "email#{n}@email.com", document_number: "#{n}"*9 }}
  end

  factory :verification_handler_field_assignment, class: Verification::Handler::FieldAssignment do
    verification_field
    handler { "residents" }

    trait :remote_census do
      handler { "remote_census" }
    end
  end

  factory :verification_residents_import, class: "Verification::Residents::Import" do
    file {
      path = %w[spec fixtures files verification residents import valid.csv]
      Rack::Test::UploadedFile.new(Rails.root.join(*path))
    }
  end
end
