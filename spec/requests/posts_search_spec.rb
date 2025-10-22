require 'rails_helper'

RSpec.describe "Posts Search", type: :request do
  let!(:post1) { create(:post, title: "Ruby on Rails", description: "A web framework") }
  let!(:post2) { create(:post, title: "JavaScript Guide", description: "Learn about Rails and JS") }
  let!(:post3) { create(:post, title: "Python Tutorial", description: "Programming with Python") }

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
        expect(response.body).to include("の検索結果: 2件")
      end
    end
  end
end
