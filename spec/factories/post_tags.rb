FactoryBot.define do
  factory :post_tag do
    association :post
    association :tag

    # 特定のpost/tagの組み合わせを作るトレイト
    trait :with_ruby_tag do
      association :tag, factory: [ :tag, :ruby ]
    end

    trait :with_rails_tag do
      association :tag, factory: [ :tag, :rails ]
    end

    trait :with_javascript_tag do
      association :tag, factory: [ :tag, :javascript ]
    end
  end
end
