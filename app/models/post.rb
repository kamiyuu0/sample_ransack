class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 1000 }

  # Ransack設定：検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    %w[title description]
  end

  # Ransack設定：検索可能な関連を定義
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
