class Spree::WinbankPayment < ApplicationRecord
    validates :transaction_ticket, presence :true, uniqueness: {case_sensitive: false}

    belongs_to :payment
end
  