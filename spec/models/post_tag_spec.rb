require 'rails_helper'

RSpec.describe PostTag, type: :model do
  describe "バリデーション" do
    let(:post) { create(:post) }
    let(:tag) { create(:tag) }

    it "有効な属性でpost_tagが作成できる" do
      post_tag = build(:post_tag, post: post, tag: tag)
      expect(post_tag).to be_valid
    end

    describe "post_idとtag_idの組み合わせのユニーク性" do
      it "同じpost_idとtag_idの組み合わせは重複して作成できない" do
        create(:post_tag, post: post, tag: tag)
        duplicate_post_tag = build(:post_tag, post: post, tag: tag)
        expect(duplicate_post_tag).not_to be_valid
        expect(duplicate_post_tag.errors[:post_id]).to include("has already been taken")
      end

      it "異なるpostに同じtagを関連付けることはできる" do
        post2 = create(:post)
        create(:post_tag, post: post, tag: tag)
        post_tag2 = build(:post_tag, post: post2, tag: tag)
        expect(post_tag2).to be_valid
      end

      it "同じpostに異なるtagを関連付けることはできる" do
        tag2 = create(:tag)
        create(:post_tag, post: post, tag: tag)
        post_tag2 = build(:post_tag, post: post, tag: tag2)
        expect(post_tag2).to be_valid
      end
    end

    describe "必須フィールド" do
      it "postが必須" do
        post_tag = build(:post_tag, post: nil, tag: tag)
        expect(post_tag).not_to be_valid
        expect(post_tag.errors[:post]).to include("must exist")
      end

      it "tagが必須" do
        post_tag = build(:post_tag, post: post, tag: nil)
        expect(post_tag).not_to be_valid
        expect(post_tag.errors[:tag]).to include("must exist")
      end
    end
  end

  describe "関連付け" do
    let(:post) { create(:post) }
    let(:tag) { create(:tag) }
    let(:post_tag) { create(:post_tag, post: post, tag: tag) }

    it "postに belongs_to している" do
      expect(post_tag.post).to eq(post)
    end

    it "tagに belongs_to している" do
      expect(post_tag.tag).to eq(tag)
    end

    it "postを削除するとpost_tagも削除される" do
      post_tag_id = post_tag.id
      post.destroy
      expect(PostTag.find_by(id: post_tag_id)).to be_nil
    end

    it "tagを削除するとpost_tagも削除される" do
      post_tag_id = post_tag.id
      tag.destroy
      expect(PostTag.find_by(id: post_tag_id)).to be_nil
    end
  end

  describe "データベース操作" do
    let(:post) { create(:post) }
    let(:tag) { create(:tag) }

    it "post_tagが正常に保存される" do
      post_tag = build(:post_tag, post: post, tag: tag)
      expect { post_tag.save! }.not_to raise_error
    end

    it "post_tagが正常に削除される" do
      post_tag = create(:post_tag, post: post, tag: tag)
      expect { post_tag.destroy! }.not_to raise_error
    end

    it "複数のpost_tagを作成できる" do
      tag2 = create(:tag)
      tag3 = create(:tag)

      expect {
        create(:post_tag, post: post, tag: tag)
        create(:post_tag, post: post, tag: tag2)
        create(:post_tag, post: post, tag: tag3)
      }.to change(PostTag, :count).by(3)
    end
  end

  describe "属性アクセス" do
    let(:post) { create(:post) }
    let(:tag) { create(:tag) }
    let(:post_tag) { create(:post_tag, post: post, tag: tag) }

    it "post_idが正しく取得できる" do
      expect(post_tag.post_id).to eq(post.id)
    end

    it "tag_idが正しく取得できる" do
      expect(post_tag.tag_id).to eq(tag.id)
    end

    it "created_atが設定されている" do
      expect(post_tag.created_at).to be_present
    end

    it "updated_atが設定されている" do
      expect(post_tag.updated_at).to be_present
    end
  end

  describe "ファクトリのトレイト" do
    it ":with_ruby_tagトレイトが正常に動作する" do
      post_tag = create(:post_tag, :with_ruby_tag)
      expect(post_tag.tag.name).to eq("Ruby")
    end

    it ":with_rails_tagトレイトが正常に動作する" do
      post_tag = create(:post_tag, :with_rails_tag)
      expect(post_tag.tag.name).to eq("Rails")
    end

    it ":with_javascript_tagトレイトが正常に動作する" do
      post_tag = create(:post_tag, :with_javascript_tag)
      expect(post_tag.tag.name).to eq("JavaScript")
    end
  end
end
