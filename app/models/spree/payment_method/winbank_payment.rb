module Spree
    class PaymentMethod::WinbankPayment < ::Spree::PaymentMethod
      def actions
        %w{capture void}
      end
  
      # Indicates whether its possible to capture the payment
      def can_capture?(payment)
        ['checkout', 'pending'].include?(payment.state)
      end
  
      # Indicates whether its possible to void the payment.
      def can_void?(payment)
        payment.state != 'void'
      end
  
      def capture(*args)
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end
  
      def cancel(response); end
  
      def void(*args)
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end
  
      def source_required?
        false
      end

      def purchase(money_in_cents, source, gateway_options)
        puts 'ppppppp', money_in_cents, source, gateway_options
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end
  
      def authorize(money_in_cents, source, gateway_options)
        puts 'aaaaaaaaaaaaa', money_in_cents, source, gateway_options
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end
    end
end