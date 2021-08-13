# frozen_string_literal: true

# == Route Map
#
# ruby/3.0.2 isn't supported by this pry-doc version

Rails.application.routes.draw do  
  resources :players, only: [:create] do 
    collection do
      # エンドポイントだけRestfulにしている
      put 'current_location', to: 'players#multi_update_current_location'
      put 'status', to: 'players#multi_update_status'
    end
    member do
      put 'inventory', to: 'players#update_inventory'      
    end
  end

  resources :reports, only: [:index]
end
