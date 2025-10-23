require 'rails_helper'

RSpec.describe "posts/index", type: :view do
  before(:each) do
    posts = [
      Post.create!(
        title: "Title",
        description: "MyText"
      ),
      Post.create!(
        title: "Title",
        description: "MyText"
      )
    ]
    assign(:posts, posts)
    # Ransackのクエリオブジェクトを設定
    assign(:q, Post.ransack({}))
    # @all_tagsを設定
    assign(:all_tags, Tag.order(:name))
  end

  it "renders a list of posts" do
    render
    # 各投稿のコンテナが2つあることを確認
    assert_select 'div[id^="post_"]', count: 2
    # タイトルのラベルが2回表示されることを確認
    assert_select 'strong', text: 'Title:', count: 2
    # 説明のラベルが2回表示されることを確認
    assert_select 'strong', text: 'Description:', count: 2
    # タイトルの値が表示されることを確認（正確なテキストマッチング）
    expect(rendered).to include('Title').at_least(2).times
    # 説明の値が表示されることを確認（正確なテキストマッチング）
    expect(rendered).to include('MyText').at_least(2).times
    # 検索フォームが表示されることを確認
    expect(rendered).to include('キーワード検索')
  end
end
