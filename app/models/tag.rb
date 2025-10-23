class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, uniqueness: true, length: { maximum: 20 }

  # namesのtagオブジェクトをdbから探す、なければ作成して返すメソッド
  def self.find_or_create_by_names(names)
    names.map { |name| find_or_create_by(name: name.strip) if name.strip.present? }.compact
  end
end
