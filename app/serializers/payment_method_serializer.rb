class PaymentMethodSerializer < Spree::V2::Storefront::PaymentMethodSerializer
    # TODO remove when original repo is updated
    attribute :preferences do |object|
        object.public_preferences.as_json
    end
end