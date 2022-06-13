module Spree::PaymentMethodDecorator
    def self.prepended(base)
        base.preference :acquirer_id, :integer
        base.preference :merchant_id, :integer
        base.preference :pos_id, :integer
        base.preference :user_name, :string
        base.preference :password, :string
        base.preference :new_ticket_url, :string

        base.preference :confirm_url, :string
        base.preference :cancel_url, :string
    end

    protected
    def public_preference_keys
        [:new_ticket_url, :acquirer_id, :merchant_id, :pos_id, :user_name]
    end
end
  
::Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)