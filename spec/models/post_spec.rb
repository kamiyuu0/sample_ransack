require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "バリデーション" do
    it "有効な属性で投稿が作成できる" do
      post = build(:post)
      expect(post).to be_valid
    end

    describe "titleのバリデーション" do
      it "titleが空の場合は無効" do
        post = build(:post, title: "")
        expect(post).not_to be_valid
        expect(post.errors[:title]).to include("can't be blank")
      end

      it "titleがnilの場合は無効" do
        post = build(:post, title: nil)
        expect(post).not_to be_valid
      end

      it "titleが255文字以下の場合は有効" do
        post = build(:post, title: "a" * 255)
        expect(post).to be_valid
      end

      it "titleが255文字を超える場合は無効" do
        post = build(:post, title: "a" * 256)
        expect(post).not_to be_valid
        expect(post.errors[:title]).to include("is too long (maximum is 255 characters)")
      end
    end

    describe "descriptionのバリデーション" do
      it "descriptionが空の場合は無効" do
        post = build(:post, description: "")
        expect(post).not_to be_valid
        expect(post.errors[:description]).to include("can't be blank")
      end

      it "descriptionがnilの場合は無効" do
        post = build(:post, description: nil)
        expect(post).not_to be_valid
      end

      it "descriptionが1000文字以下の場合は有効" do
        post = build(:post, description: "a" * 1000)
        expect(post).to be_valid
      end

      it "descriptionが1000文字を超える場合は無効" do
        post = build(:post, description: "a" * 1001)
        expect(post).not_to be_valid
        expect(post.errors[:description]).to include("is too long (maximum is 1000 characters)")
      end
    end
  end

  describe "データベース操作" do
    it "投稿が正常に保存される" do
      post = build(:post)
      expect { post.save! }.not_to raise_error
    end

    it "投稿が正常に削除される" do
      post = create(:post)
      expect { post.destroy! }.not_to raise_error
    end

    it "投稿が正常に更新される" do
      post = create(:post)
      expect { post.update!(title: "更新されたタイトル") }.not_to raise_error
      expect(post.reload.title).to eq("更新されたタイトル")
    end
  end

  describe "属性アクセス" do
    let(:post) { create(:post, title: "テストタイトル", description: "テスト説明") }

    it "titleが正しく取得できる" do
      expect(post.title).to eq("テストタイトル")
    end

    it "descriptionが正しく取得できる" do
      expect(post.description).to eq("テスト説明")
    end

    it "created_atが設定されている" do
      expect(post.created_at).to be_present
    end

    it "updated_atが設定されている" do
      expect(post.updated_at).to be_present
    end
  end
end
