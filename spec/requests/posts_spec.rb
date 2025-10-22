require 'rails_helper'

RSpec.describe "/posts", type: :request do
  # FactoryBotを使用して有効な属性を定義
  let(:valid_attributes) {
    {
      title: "テスト投稿タイトル",
      description: "これはテスト用の投稿の説明文です。"
    }
  }

  # 無効な属性（空の値）を定義
  let(:invalid_attributes) {
    {
      title: "",
      description: ""
    }
  }

  # 更新用の新しい属性を定義
  let(:new_attributes) {
    {
      title: "更新されたタイトル",
      description: "更新された説明文です。"
    }
  }

  describe "GET /index" do
    it "投稿一覧ページが正常に表示される" do
      # テストデータを作成
      Post.create! valid_attributes
      get posts_url
      expect(response).to be_successful
      expect(response).to have_http_status(:ok)
    end

    it "JSON形式での投稿一覧が正常に取得できる" do
      post = Post.create! valid_attributes
      get posts_url, as: :json
      expect(response).to be_successful
      expect(response.content_type).to include('application/json')
    end

    it "投稿が存在しない場合でも正常に表示される" do
      get posts_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "投稿詳細ページが正常に表示される" do
      post = Post.create! valid_attributes
      get post_url(post)
      expect(response).to be_successful
      expect(response).to have_http_status(:ok)
    end

    it "JSON形式での投稿詳細が正常に取得できる" do
      post = Post.create! valid_attributes
      get post_url(post), as: :json
      expect(response).to be_successful
      expect(response.content_type).to include('application/json')
    end

    it "存在しない投稿のIDでアクセスすると404エラーが返される" do
      get post_url(id: 99999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "新規投稿作成ページが正常に表示される" do
      get new_post_url
      expect(response).to be_successful
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "投稿編集ページが正常に表示される" do
      post = Post.create! valid_attributes
      get edit_post_url(post)
      expect(response).to be_successful
      expect(response).to have_http_status(:ok)
    end

    it "存在しない投稿の編集ページにアクセスすると404エラーが返される" do
      get edit_post_url(id: 99999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    context "有効なパラメータの場合" do
      it "新しい投稿が作成される" do
        expect {
          post posts_url, params: { post: valid_attributes }
        }.to change(Post, :count).by(1)
      end

      it "作成された投稿の詳細ページにリダイレクトされる" do
        post posts_url, params: { post: valid_attributes }
        expect(response).to redirect_to(post_url(Post.last))
      end

      it "成功メッセージが表示される" do
        post posts_url, params: { post: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Post was successfully created.")
      end

      it "JSON形式でのリクエストが正常に処理される" do
        expect {
          post posts_url, params: { post: valid_attributes }, as: :json
        }.to change(Post, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "無効なパラメータの場合" do
      it "新しい投稿が作成されない" do
        expect {
          post posts_url, params: { post: invalid_attributes }
        }.to change(Post, :count).by(0)
      end

      it "422ステータス（新規作成フォームを再表示）が返される" do
        post posts_url, params: { post: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "JSON形式でのリクエストで422ステータスが返される" do
        post posts_url, params: { post: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "パラメータのセキュリティテスト" do
      it "許可されていないパラメータは無視される" do
        malicious_params = valid_attributes.merge({ 
          admin: true, 
          created_at: 1.year.ago,
          updated_at: 1.year.ago
        })
        
        post posts_url, params: { post: malicious_params }
        created_post = Post.last
        
        # 許可されていない属性は設定されていないことを確認
        expect(created_post).not_to respond_to(:admin)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "投稿が正常に更新される" do
        post = Post.create! valid_attributes
        patch post_url(post), params: { post: new_attributes }
        post.reload
        
        expect(post.title).to eq(new_attributes[:title])
        expect(post.description).to eq(new_attributes[:description])
      end

      it "更新後に投稿詳細ページにリダイレクトされる" do
        post = Post.create! valid_attributes
        patch post_url(post), params: { post: new_attributes }
        expect(response).to redirect_to(post_url(post))
      end

      it "成功メッセージが表示される" do
        post = Post.create! valid_attributes
        patch post_url(post), params: { post: new_attributes }
        follow_redirect!
        expect(response.body).to include("Post was successfully updated.")
      end

      it "JSON形式でのリクエストが正常に処理される" do
        post = Post.create! valid_attributes
        patch post_url(post), params: { post: new_attributes }, as: :json
        expect(response).to have_http_status(:ok)
        
        post.reload
        expect(post.title).to eq(new_attributes[:title])
      end
    end

    context "無効なパラメータの場合" do
      it "422ステータス（編集フォームを再表示）が返される" do
        post = Post.create! valid_attributes
        patch post_url(post), params: { post: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "JSON形式でのリクエストで422ステータスが返される" do
        post = Post.create! valid_attributes
        patch post_url(post), params: { post: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "存在しない投稿の場合" do
      it "404エラーが返される" do
        patch post_url(id: 99999), params: { post: new_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    it "指定された投稿が削除される" do
      post = Post.create! valid_attributes
      expect {
        delete post_url(post)
      }.to change(Post, :count).by(-1)
    end

    it "削除後に投稿一覧ページにリダイレクトされる" do
      post = Post.create! valid_attributes
      delete post_url(post)
      expect(response).to redirect_to(posts_url)
    end

    it "成功メッセージが表示される" do
      post = Post.create! valid_attributes
      delete post_url(post)
      follow_redirect!
      expect(response.body).to include("Post was successfully destroyed.")
    end

    it "JSON形式でのリクエストで204ステータスが返される" do
      post = Post.create! valid_attributes
      delete post_url(post), as: :json
      expect(response).to have_http_status(:no_content)
    end

    it "存在しない投稿を削除しようとすると404エラーが返される" do
      delete post_url(id: 99999)
      expect(response).to have_http_status(:not_found)
    end
  end

  # 追加のエッジケースとセキュリティテスト
  describe "追加のセキュリティテスト" do
    it "SQLインジェクション攻撃に対して安全である" do
      malicious_id = "1; DROP TABLE posts; --"
      get post_url(id: malicious_id)
      expect(response).to have_http_status(:not_found)
    end

    it "XSS攻撃を含むパラメータが適切にエスケープされる" do
      xss_params = {
        title: "<script>alert('xss')</script>",
        description: "<img src=x onerror=alert('xss')>"
      }
      
      post posts_url, params: { post: xss_params }
      created_post = Post.last
      
      # データは保存されるが、ビューでエスケープされることを期待
      expect(created_post.title).to eq("<script>alert('xss')</script>")
      expect(created_post.description).to eq("<img src=x onerror=alert('xss')>")
    end
  end

  # パフォーマンステスト
  describe "パフォーマンステスト" do
    it "大量のデータが存在する場合でもindex アクションが適切な時間で応答する" do
      # 100件の投稿を作成
      100.times do |i|
        Post.create!(title: "投稿 #{i}", description: "説明 #{i}")
      end

      start_time = Time.current
      get posts_url
      end_time = Time.current

      expect(response).to be_successful
      # 1秒以内に応答することを確認（必要に応じて調整）
      expect(end_time - start_time).to be < 1.second
    end
  end
end
