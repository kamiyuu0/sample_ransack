FactoryBot.define do
  factory :post do
    title { "サンプル投稿タイトル" }
    description { "これはサンプル投稿の説明文です。テスト用に作成されました。" }

    # バリエーションを追加
    trait :with_long_title do
      title { "これは非常に長いタイトルのサンプルです。" * 5 }
    end

    trait :with_long_description do
      description { "これは非常に長い説明文のサンプルです。" * 20 }
    end

    trait :invalid do
      title { "" }
      description { "" }
    end

    # タグ関連のトレイト
    trait :with_tags do
      after(:create) do |post|
        post.tags << create(:tag, name: "Ruby")
        post.tags << create(:tag, name: "Rails")
      end
    end

    trait :with_ruby_tag do
      after(:create) do |post|
        post.tags << create(:tag, name: "Ruby")
      end
    end

    trait :with_rails_tag do
      after(:create) do |post|
        post.tags << create(:tag, name: "Rails")
      end
    end

    trait :with_javascript_tag do
      after(:create) do |post|
        post.tags << create(:tag, name: "JavaScript")
      end
    end

    trait :with_multiple_tags do
      after(:create) do |post|
        post.tags << create(:tag, name: "Ruby")
        post.tags << create(:tag, name: "Rails")
        post.tags << create(:tag, name: "JavaScript")
        post.tags << create(:tag, name: "React")
      end
    end

    # シーケンスを使用してユニークなデータを生成
    factory :post_with_sequence do
      sequence(:title) { |n| "投稿タイトル #{n}" }
      sequence(:description) { |n| "投稿説明 #{n}" }
    end
  end
end
