# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# タグのサンプルデータを作成
tag_names = [
  "Ruby", "Rails", "JavaScript", "HTML", "CSS",
  "プログラミング", "Web開発", "フロントエンド", "バックエンド", "データベース",
  "初心者", "中級者", "上級者", "チュートリアル", "tips"
]

tags = tag_names.map do |name|
  Tag.find_or_create_by(name: name)
end

puts "#{tags.size}個のTagを作成しました。"

# Post用のサンプルデータを作成（タグも関連付け）
30.times do |i|
  post = Post.find_or_create_by(title: "サンプル投稿 #{i + 1}") do |p|
    p.description = "これは#{i + 1}番目のサンプル投稿です。Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  end

  # 各投稿に1〜4個のランダムなタグを関連付け
  if post.tags.empty?
    random_tags = tags.sample(rand(1..4))
    post.tags = random_tags
  end
end

puts "30件のPostを作成し、タグを関連付けました。"
