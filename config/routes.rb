Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do  
    namespace :v2 do
      namespace :storefront do
        get '/winbank/issueticket/:order_number', to: 'winbank#issueticket'
      end
    end
  end
end