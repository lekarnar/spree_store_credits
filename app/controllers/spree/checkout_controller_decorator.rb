module Spree
  CheckoutController.class_eval do
    before_filter :remove_payments_attributes_if_total_is_zero

    [:store_credit_amount, :remove_store_credits].each do |attrib|
      Spree::PermittedAttributes.checkout_attributes << attrib unless Spree::PermittedAttributes.checkout_attributes.include?(attrib)
    end

    def insufficient_payment?

      if params[:order] && store_credits_amount = params[:order][:store_credit_amount]
        @order.store_credit_amount = store_credits_amount
        @order.send :process_store_credit
      end

      params[:state] == "confirm" &&
        @order.payment_required? &&
        @order.reload.payments.valid.sum(:amount) != @order.total
    end

    private

    def remove_payments_attributes_if_total_is_zero
      load_order_with_lock
      return unless params[:order] && params[:order][:store_credit_amount]
      @order.decrement!(:state_lock_version) if params[:order][:state_lock_version]
      parsed_credit = Spree::Price.new
      parsed_credit.price = params[:order][:store_credit_amount]
      store_credit_amount = [parsed_credit.price, spree_current_user.store_credits_total].min
      return unless store_credit_amount >= (current_order.total + @order.store_credit_amount)
      params[:order].delete(:source_attributes)
      params.delete(:payment_source)
      params[:order].delete(:payments_attributes)
    end
  end
end
