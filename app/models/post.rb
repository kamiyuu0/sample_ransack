class Post < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 1000 }

  attr_accessor :tag_names

  after_save :save_tags

  # タグ名をカンマ区切り文字列で返す
  def tag_names_as_string
    tags.pluck(:name).join(", ")
  end

  # Ransack設定：検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[title description]
  end

  # Ransack設定：検索可能な関連を定義
  def self.ransackable_associations(auth_object = nil)
    %w[tags]
  end

  private

  # タグ名の保存処理
  def save_tags
    return unless tag_names

    # カンマで分割してタグ名の配列を作成
    tag_name_array = tag_names.split(",").map(&:strip).reject(&:blank?)

    # 既存のタグとの関連を削除
    post_tags.destroy_all

    # 新しいタグとの関連を作成
    if tag_name_array.any?
      new_tags = Tag.find_or_create_by_names(tag_name_array)
      self.tags = new_tags
    end
  end
end
