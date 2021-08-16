# frozen_string_literal: true

# == Route Map
#
# ruby/3.0.2 isn't supported by this pry-doc version

Rails.application.routes.draw do
  resources :players, only: [:create] do
    collection do
    end
    member do
      put 'inventory', to: 'players#update_inventory'
    end
  end

  # 全体のプレイヤーに関することなのでplayerではなくfiledにしている
  namespace :filed do
    put 'current_location'
    put 'infection'
  end
  resources :filed, only: [:index]
end
