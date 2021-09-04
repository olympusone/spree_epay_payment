module Spree::PaymentMethodDecorator
    def self.prepended(base)
        base.preference :acquirer_id, :integer
        base.preference :merchant_id, :integer
        base.preference :pos_id, :integer
        base.preference :user_name, :string
        base.preference :password, :string
    end

    # TODO remove when original repo is updated
    def public_preferences
        public_preference_keys.each_with_object({}) do |key, hash|
          hash[key] = preferences[key]
        end
    end

    protected
    def public_preference_keys
        [:acquirer_id, :merchant_id, :pos_id, :user_name]
    end
end
  
::Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)