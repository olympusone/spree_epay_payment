module Spree
    class WinbankPayment < Spree::Base
        validates :transaction_ticket, presence: true, uniqueness: {case_sensitive: false}
    
        belongs_to :payment

        default_scope { order id: :desc}
    end
end