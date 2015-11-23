class Spree::StoreCredit < ActiveRecord::Base
  validates :amount, numericality: true
  validates :amount, :reason, :user, presence: true
  if Spree.user_class
    belongs_to :user, class_name: Spree.user_class.to_s
  else
    belongs_to :user
  end

  scope :user, ->(user_id) {user_id ? Spree::StoreCredit.where(user_id: user_id) : Spree::StoreCredit.all}

end
