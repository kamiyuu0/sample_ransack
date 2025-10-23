class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true, uniqueness: true, length: { maximum: 20 }

  # Ransack設定：検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  # namesのtagオブジェクトをdbから探す、なければ作成して返すメソッド
  def self.find_or_create_by_names(names)
    names.map { |name| find_or_create_by(name: name.strip) if name&.strip&.present? }.compact
  end
end
