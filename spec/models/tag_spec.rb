require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "バリデーション" do
    it "有効な属性でタグが作成できる" do
      tag = build(:tag)
      expect(tag).to be_valid
    end

    describe "nameのバリデーション" do
      it "nameが空の場合は無効" do
        tag = build(:tag, name: "")
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("can't be blank")
      end

      it "nameがnilの場合は無効" do
        tag = build(:tag, name: nil)
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("can't be blank")
      end

      it "nameが20文字以下の場合は有効" do
        tag = build(:tag, name: "a" * 20)
        expect(tag).to be_valid
      end

      it "nameが20文字を超える場合は無効" do
        tag = build(:tag, name: "a" * 21)
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include("is too long (maximum is 20 characters)")
      end

      it "同じnameのタグは作成できない（uniqueness）" do
        create(:tag, name: "Ruby")
        duplicate_tag = build(:tag, name: "Ruby")
        expect(duplicate_tag).not_to be_valid
        expect(duplicate_tag.errors[:name]).to include("has already been taken")
      end
    end
  end

  describe "関連付け" do
    let(:tag) { create(:tag) }
    let(:post1) { create(:post) }
    let(:post2) { create(:post) }

    it "post_tagsを持つ" do
      expect(tag).to respond_to(:post_tags)
    end

    it "postsを持つ" do
      expect(tag).to respond_to(:posts)
    end

    it "複数のpostと関連付けできる" do
      tag.posts << post1
      tag.posts << post2
      expect(tag.posts.count).to eq(2)
      expect(tag.posts).to include(post1, post2)
    end

    it "タグが削除されるとpost_tagsも削除される" do
      tag.posts << post1
      post_tag_id = tag.post_tags.first.id
      tag.destroy
      expect(PostTag.find_by(id: post_tag_id)).to be_nil
    end
  end

  describe "データベース操作" do
    it "タグが正常に保存される" do
      tag = build(:tag)
      expect { tag.save! }.not_to raise_error
    end

    it "タグが正常に削除される" do
      tag = create(:tag)
      expect { tag.destroy! }.not_to raise_error
    end

    it "タグが正常に更新される" do
      tag = create(:tag)
      expect { tag.update!(name: "更新されたタグ") }.not_to raise_error
      expect(tag.reload.name).to eq("更新されたタグ")
    end
  end

  describe ".find_or_create_by_names" do
    it "存在しないタグ名の場合は新しいタグを作成する" do
      names = [ "Ruby", "Rails", "JavaScript" ]
      expect { Tag.find_or_create_by_names(names) }.to change(Tag, :count).by(3)
    end

    it "存在するタグ名の場合は既存のタグを返す" do
      create(:tag, name: "Ruby")
      names = [ "Ruby", "Rails" ]
      expect { Tag.find_or_create_by_names(names) }.to change(Tag, :count).by(1)
    end

    it "空文字やnilを含む配列でも正常に処理する" do
      names = [ "Ruby", "", nil, "  ", "Rails" ]
      result = Tag.find_or_create_by_names(names)
      expect(result.map(&:name)).to eq([ "Ruby", "Rails" ])
    end

    it "名前の前後の空白を削除して処理する" do
      names = [ "  Ruby  ", " Rails ", "JavaScript" ]
      result = Tag.find_or_create_by_names(names)
      expect(result.map(&:name)).to eq([ "Ruby", "Rails", "JavaScript" ])
    end

    it "重複した名前を含む配列でもユニークなタグのみ作成する" do
      names = [ "Ruby", "Ruby", "Rails" ]
      expect { Tag.find_or_create_by_names(names) }.to change(Tag, :count).by(2)
    end

    it "空の配列の場合は空の配列を返す" do
      result = Tag.find_or_create_by_names([])
      expect(result).to eq([])
    end

    it "すべてが空文字やnilの場合は空の配列を返す" do
      names = [ "", nil, "  ", "   " ]
      result = Tag.find_or_create_by_names(names)
      expect(result).to eq([])
    end
  end

  describe "属性アクセス" do
    let(:tag) { create(:tag, name: "テストタグ") }

    it "nameが正しく取得できる" do
      expect(tag.name).to eq("テストタグ")
    end

    it "created_atが設定されている" do
      expect(tag.created_at).to be_present
    end

    it "updated_atが設定されている" do
      expect(tag.updated_at).to be_present
    end
  end
end
