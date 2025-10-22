# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Post用のサンプルデータを作成
30.times do |i|
  Post.find_or_create_by!(
    title: "サンプル投稿 #{i + 1}",
    description: "これは#{i + 1}番目のサンプル投稿です。Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  )
end

puts "30件のPostを作成しました。"
