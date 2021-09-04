module Spree
    class WinbankPayment < Spree::Base
        validates :transaction_ticket, presence: true, uniqueness: {case_sensitive: false}
        validates :support_reference_id, presence: true, uniqueness: {case_sensitive: false}
        validates_presence_of :result_code, :result_description, :status_flag
    
        belongs_to :payment

        default_scope { order id: :desc}
    end
end