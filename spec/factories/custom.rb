FactoryBot.define do
  factory :poll_nvote, class: "Poll::Nvote" do
    user
    poll
  end

  factory :volunteer_poll do
    sequence(:email)      { |n| "volunteer#{n}@consul.dev" }
    sequence(:first_name) { |n| "volunteer#{n} first name" }
    sequence(:last_name)  { |n| "volunteer#{n} last name" }
    sequence(:document_number) { |n| "12345#{n}" }
    sequence(:phone)      { |n| "6061111#{n}" }
    turns "3 turnos"
  end

  factory :probe do
    sequence(:codename) { |n| "probe_#{n}" }
  end

  factory :probe_option do
    probe
    sequence(:name) { |n| "Probe option #{n}" }
    sequence(:code) { |n| "probe_option_#{n}" }
  end
end
