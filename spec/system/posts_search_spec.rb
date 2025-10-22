require 'rails_helper'

RSpec.describe "Posts Search", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:post1) { create(:post, title: "Ruby on Rails Tutorial", description: "Learn web development with Rails") }
  let!(:post2) { create(:post, title: "JavaScript Fundamentals", description: "Master JavaScript basics") }
  let!(:post3) { create(:post, title: "Python for Beginners", description: "Start your journey with Python") }

  scenario "User can search posts by keyword" do
    visit posts_path

    # 全ての投稿が表示されることを確認
    expect(page).to have_content("全件表示: 3件")
    expect(page).to have_content(post1.title)
    expect(page).to have_content(post2.title)
    expect(page).to have_content(post3.title)

    # キーワードで検索
    fill_in "キーワード検索", with: "Rails"
    click_button "検索"

    # 検索結果の確認
    expect(page).to have_content("「Rails」の検索結果: 1件")
    expect(page).to have_content(post1.title)
    expect(page).not_to have_content(post2.title)
    expect(page).not_to have_content(post3.title)
  end

  scenario "User can search posts by description" do
    visit posts_path

    # 説明文で検索
    fill_in "キーワード検索", with: "JavaScript"
    click_button "検索"

    # 検索結果の確認
    expect(page).to have_content("「JavaScript」の検索結果: 1件")
    expect(page).to have_content(post2.title)
    expect(page).not_to have_content(post1.title)
    expect(page).not_to have_content(post3.title)
  end

  scenario "User sees appropriate message when no results found" do
    visit posts_path

    # 存在しないキーワードで検索
    fill_in "キーワード検索", with: "NonExistentKeyword"
    click_button "検索"

    # 検索結果なしのメッセージを確認
    expect(page).to have_content("「NonExistentKeyword」に一致する投稿が見つかりませんでした")
    expect(page).to have_link("全ての投稿を表示")
  end

  scenario "User can clear search results" do
    visit posts_path

    # 検索を実行
    fill_in "キーワード検索", with: "Rails"
    click_button "検索"

    expect(page).to have_content("「Rails」の検索結果: 1件")

    # クリアボタンをクリック
    click_link "クリア"

    # 全件表示に戻ることを確認
    expect(page).to have_content("全件表示: 3件")
    expect(page).to have_content(post1.title)
    expect(page).to have_content(post2.title)
    expect(page).to have_content(post3.title)
  end

  scenario "Search form maintains entered keyword" do
    visit posts_path

    # キーワードを入力して検索
    fill_in "キーワード検索", with: "Python"
    click_button "検索"

    # 検索フォームにキーワードが保持されていることを確認
    expect(page).to have_field("キーワード検索", with: "Python")
    expect(page).to have_content("「Python」の検索結果: 1件")
  end
end
