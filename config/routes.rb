Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do  
    namespace :v2 do
      namespace :storefront do
        resources :winbank_payments, only: [:create]
      end
    end
  end
end