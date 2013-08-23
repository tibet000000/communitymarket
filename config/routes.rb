Communitymarket::Application.routes.draw do




  resources :email_settings


  # resources :posts do
  #   resources :transactions
  # end
  
  resources :transactions
  resources :memberships do
    collection do
      put :update_individual
    end
  end
  resources :followships
  resources :tags

  resources :users do
    collection do
      get :new_modal
    end
    resources :posts
    resources :groups
  end
  
  get 'users/new_modal'
  
  # member do
  #   get :new_modal
  # end
  
  resources :images
  resources :group_categories
  resources :post_categories
  resources :sessions, :only => [:new, :create, :destroy]
  resources :groups do
    collection do
      put :private
    end
  end

  resource :session, controller: 'sessions'

  resources :posts do
    collection do
      get :sort_name
    end
    member do
      get :deactivate
      get :reactivate
    end
    resources :assignments
  end
  
  match '/groups/nearby', :to => "groups#nearby"
  match '/search', :to => 'search#index'
  match '/about', :to => 'pages#about'
  match '/signout', :to => 'sessions#destroy'
  match '/sign_in', :to => 'sessions#new'
  match '/signin', :to => 'sessions#new'
  match '/invites', :to => 'invites#new'
  root :to => 'pages#index'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
