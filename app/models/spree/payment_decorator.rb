module Spree::PaymentDecorator
    def self.prepended(base)
      base.has_many :epay_payments, dependent: :destroy
    end
end
  
Spree::Payment.prepend Spree::PaymentDecorator
  