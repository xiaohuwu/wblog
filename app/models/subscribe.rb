class Subscribe < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: '地址无效' }

  def self.subscribe_list
    Subscribe.all.where(enable: true).map(&:email)
  end

  def self.unsubscribe_list
    Subscribe.all.where(enable: false).map(&:email)
  end

  def self.unsubscribe?(email)
    Subscribe.where(email: email, enable: false).first.present?
  end
end
