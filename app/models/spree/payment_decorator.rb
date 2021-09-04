module Spree::PaymentDecorator
    def self.prepended(base)
      base.has_one :winbank_payment, dependent: :destroy
    end
end
  
Spree::Payment.prepend Spree::PaymentDecorator
  