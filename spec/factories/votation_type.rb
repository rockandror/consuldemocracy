FactoryBot.define do
  factory :votation_type do
    factory :votation_type_unique do
      vote_type { "unique" }
    end

    factory :votation_type_multiple do
      vote_type { "multiple" }
      max_votes { 3 }
    end

    factory :votation_type_open do
      vote_type { "open" }
    end

    questionable factory: :poll_question
  end
end
