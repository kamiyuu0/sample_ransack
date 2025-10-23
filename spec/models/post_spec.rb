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

  describe "タグ関連の機能" do
    let(:post) { create(:post) }
    let(:tag1) { create(:tag, name: "Ruby") }
    let(:tag2) { create(:tag, name: "Rails") }
    let(:tag3) { create(:tag, name: "JavaScript") }

    describe "関連付け" do
      it "post_tagsを持つ" do
        expect(post).to respond_to(:post_tags)
      end

      it "tagsを持つ" do
        expect(post).to respond_to(:tags)
      end

      it "複数のtagと関連付けできる" do
        post.tags << tag1
        post.tags << tag2
        expect(post.tags.count).to eq(2)
        expect(post.tags).to include(tag1, tag2)
      end

      it "投稿が削除されるとpost_tagsも削除される" do
        post.tags << tag1
        post_tag_id = post.post_tags.first.id
        post.destroy
        expect(PostTag.find_by(id: post_tag_id)).to be_nil
      end
    end

    describe "#tag_names_as_string" do
      it "タグがない場合は空文字を返す" do
        expect(post.tag_names_as_string).to eq("")
      end

      it "1つのタグの場合はその名前を返す" do
        post.tags << tag1
        expect(post.tag_names_as_string).to eq("Ruby")
      end

      it "複数のタグの場合はカンマ区切りの文字列を返す" do
        post.tags << tag1
        post.tags << tag2
        post.tags << tag3
        expect(post.tag_names_as_string).to eq("Ruby, Rails, JavaScript")
      end
    end

    describe "tag_names属性とタグ保存機能" do
      it "tag_names属性を持つ" do
        expect(post).to respond_to(:tag_names)
        expect(post).to respond_to(:tag_names=)
      end

      context "新しいタグ名が設定された場合" do
        it "カンマ区切りの文字列からタグを作成・関連付けする" do
          post.tag_names = "Ruby, Rails, JavaScript"
          post.save!
          expect(post.tags.pluck(:name)).to match_array([ "Ruby", "Rails", "JavaScript" ])
        end

        it "既存のタグがある場合は既存のタグを使用する" do
          create(:tag, name: "Ruby")
          post.tag_names = "Ruby, Rails"
          expect { post.save! }.to change(Tag, :count).by(1)
          expect(post.tags.pluck(:name)).to match_array([ "Ruby", "Rails" ])
        end

        it "空白や空文字を含む場合は適切に処理する" do
          post.tag_names = "Ruby,  , Rails,  JavaScript  ,"
          post.save!
          expect(post.tags.pluck(:name)).to match_array([ "Ruby", "Rails", "JavaScript" ])
        end

        it "既存のタグ関連付けを削除して新しいタグと関連付けする" do
          post.tags << tag1
          post.tags << tag2
          post.save!

          post.tag_names = "JavaScript, Python"
          post.save!
          expect(post.tags.pluck(:name)).to match_array([ "JavaScript", "Python" ])
        end
      end

      context "tag_namesが空またはnilの場合" do
        it "既存のタグ関連付けを削除する" do
          post.tags << tag1
          post.tags << tag2
          post.save!

          post.tag_names = ""
          post.save!
          expect(post.tags.count).to eq(0)
        end

        it "tag_namesがnilの場合は何もしない" do
          post.tags << tag1
          post.save!

          post.tag_names = nil
          post.save!
          expect(post.tags.count).to eq(1)
        end
      end
    end

    describe "Ransack設定" do
      it "titleが検索可能な属性に含まれる" do
        expect(Post.ransackable_attributes).to include("title")
      end

      it "descriptionが検索可能な属性に含まれる" do
        expect(Post.ransackable_attributes).to include("description")
      end

      it "tagsが検索可能な関連に含まれる" do
        expect(Post.ransackable_associations).to include("tags")
      end
    end
  end
end
