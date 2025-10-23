FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "タグ#{n}" }

    # トレイトを定義
    trait :ruby do
      name { "Ruby" }
    end

    trait :rails do
      name { "Rails" }
    end

    trait :javascript do
      name { "JavaScript" }
    end

    trait :with_long_name do
      name { "a" * 20 }
    end

    trait :invalid_long_name do
      name { "a" * 21 }
    end

    trait :empty_name do
      name { "" }
    end

    trait :with_whitespace do
      name { "  Ruby  " }
    end
  end
end
