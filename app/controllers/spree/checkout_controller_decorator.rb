module Spree
  CheckoutController.class_eval do

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

  end
end
