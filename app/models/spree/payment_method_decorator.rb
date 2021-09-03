module Spree::PaymentMethodDecorator
    def self.prepended(base)
        base.preference :acquirer_id, :integer
        base.preference :merchant_id, :integer
        base.preference :pos_id, :integer
        base.preference :user_name, :string
        base.preference :password, :string
    end
end
  
::Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)