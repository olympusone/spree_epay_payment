# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_epay_payment/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_epay_payment'
  s.version     = SpreeEpayPayment.version
  s.summary     = 'Spree Epay Payment'
  s.description = 'You can accept Epay Piraeus Bank through ePOS payments'
  s.required_ruby_version = '>= 2.5'

  s.author       = 'OlympusOne'
  s.email        = 'info@olympusone.com'
  s.homepage     = 'https://github.com/olympusone/spree_epay_payment'
  s.license      = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 4.3.2'
  s.add_dependency 'spree', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'spree_dev_tools'
end
