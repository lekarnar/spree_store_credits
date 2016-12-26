if Spree.user_class
  Spree.user_class.class_eval do
    has_many :store_credits, class_name: 'Spree::StoreCredit'

    def has_store_credit?
      store_credits.present?
    end

    def store_credits_total
      if !store_credits.empty?
        store_credits.sum(:remaining_amount)
      else
        0
      end
    end
  end
end
