require 'rails_helper'

RSpec.describe "Posts Search", type: :request do
  let!(:ruby_tag) { create(:tag, name: "Ruby") }
  let!(:rails_tag) { create(:tag, name: "Rails") }
  let!(:js_tag) { create(:tag, name: "JavaScript") }
  let!(:python_tag) { create(:tag, name: "Python") }

  let!(:post1) { create(:post, title: "Ruby on Rails", description: "A web framework") }
  let!(:post2) { create(:post, title: "JavaScript Guide", description: "Learn about Rails and JS") }
  let!(:post3) { create(:post, title: "Python Tutorial", description: "Programming with Python") }

  before do
    # タグを投稿に関連付け
    post1.tags = [ ruby_tag, rails_tag ]
    post2.tags = [ js_tag, rails_tag ]
    post3.tags = [ python_tag ]
  end

  describe "GET /posts" do
    context "without search parameters" do
      it "returns all posts" do
        get posts_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post1.title)
        expect(response.body).to include(post2.title)
        expect(response.body).to include(post3.title)
      end
    end

    context "with search parameters" do
      it "searches by title" do
        get posts_path, params: { q: { title_or_description_cont: "Rails" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post1.title)
        expect(response.body).to include(post2.title)
        expect(response.body).not_to include(post3.title)
      end

      it "searches by description" do
        get posts_path, params: { q: { title_or_description_cont: "Python" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post3.title)
        expect(response.body).not_to include(post1.title)
        expect(response.body).not_to include(post2.title)
      end

      it "searches case-insensitively" do
        get posts_path, params: { q: { title_or_description_cont: "rails" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post1.title)
        expect(response.body).to include(post2.title)
      end

      it "returns no results for non-matching search" do
        get posts_path, params: { q: { title_or_description_cont: "NonExistent" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("一致する投稿が見つかりませんでした")
      end

      it "displays search result count" do
        get posts_path, params: { q: { title_or_description_cont: "Rails" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("検索結果: 2件")
      end
    end

    context "with tag search" do
      it "searches by single tag" do
        get posts_path, params: { q: { tags_name_in: "Ruby" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post1.title)
        expect(response.body).not_to include(post2.title)
        expect(response.body).not_to include(post3.title)
      end

      it "searches by another single tag" do
        get posts_path, params: { q: { tags_name_in: "JavaScript" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post2.title)
        expect(response.body).not_to include(post1.title)
        expect(response.body).not_to include(post3.title)
      end

      it "returns no results when tag has no posts" do
        create(:tag, name: "NonExistentTag")
        get posts_path, params: { q: { tags_name_in: "NonExistentTag" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("検索条件に一致する投稿が見つかりませんでした")
      end

      it "combines keyword and tag search" do
        get posts_path, params: { q: { title_or_description_cont: "Rails", tags_name_in: "JavaScript" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post2.title)
        expect(response.body).not_to include(post1.title)
        expect(response.body).not_to include(post3.title)
      end

      it "displays selected tag in search results" do
        get posts_path, params: { q: { tags_name_in: "Ruby" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("選択されたタグ:")
        expect(response.body).to include("Ruby")
      end

      it "shows all posts when no tag is selected" do
        get posts_path, params: { q: { tags_name_in: "" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(post1.title)
        expect(response.body).to include(post2.title)
        expect(response.body).to include(post3.title)
      end
    end
  end
end
