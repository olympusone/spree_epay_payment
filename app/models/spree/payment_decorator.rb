module Spree::PaymentDecorator
    def self.prepended(base)
      base.has_many :winbank_payments, dependent: :destroy
    end
end
  
Spree::Payment.prepend Spree::PaymentDecorator
  