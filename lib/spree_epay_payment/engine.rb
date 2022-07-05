module SpreeEpayPayment
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_epay_payment'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree.register.payment_methods', after: :after_initialize do |_app|
      _app.config.spree.payment_methods << Spree::PaymentMethod::EpayPayment
    end

    initializer 'spree_epay_payment.environment', before: :load_config_initializers do |_app|
      SpreeEpayPayment::Config = SpreeEpayPayment::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
