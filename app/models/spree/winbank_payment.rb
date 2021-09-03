class Spree::WinbankPayment < ActiveRecord::Base
    validates :transaction_ticket, presence :true, uniqueness: {case_sensitive: false}

    belongs_to :payment
end
  