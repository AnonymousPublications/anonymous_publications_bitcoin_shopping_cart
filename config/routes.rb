Rails3BootstrapDeviseCancan::Application.routes.draw do
  
  resources :stories

  match "fonts/css" => 'pages#css'
  
  match "articles" => "articles#index"
  match "poemsec" => "articles#poemsec"
  get "articles/git_tut"
  get "articles/index"
  get "articles/unboxing"
  get "articles/encrypting_email"
  get "articles/op_democracy_distro"
  get "articles/poemsec"
  get "articles/bitcoin"
  get "articles/free_expression"
  

  match "/pwtd-online-friendly" => redirect("http://imgur.com/a/j3thx"), :as => :pwtd_online
  match "/pwtd-book-rip-fast-dl" => redirect("https://mega.co.nz/#!BEYUSBQC!G6qUfaofxha1UmYKuSJ79NNkRCESTQC7UzZVmNVFw4w"), :as => :pwtd_lowql
  match "/pwtd-book-rip-quality-dl" => redirect("https://mega.co.nz/#!YBITHLrK!oV1-Gn-kgc-bfCfVGKudsl5Zymwhxa6XF4caTkRLkRU"), :as => :pwtd_ql
  
  match "/pwtd-book-rip-heavy" => redirect("https://mega.co.nz/#!kFBShD4Y!bVRx1tcjG49Yz2PZ4QLPnNfYv2WbWpWNMlrCCZjDH6E"), :as => :pwtd_heavy
  
  
  
  get "coupons/gen_coupon"
  resources :coupons


  resources :shipping_plans


  resources :discounts


  resources :pricing_rules


  resources :encryption_pairs


  resources :utilized_bitcoin_wallets


  resources :ready_for_shipment_batches


  resources :retailers


  # TODu: delete this reference, I don't use the scaffolding at all
  resources :costs_of_bitcoins

  match "delete_current_users_btc_pmt" => "test_funcs#delete_current_users_btc_pmt"
  match "new_payments_found" => "bitcoin_payments#new_payments_found"
  match "test_funcs/trigger_bitcoin_payment_found_on_next_request" => "test_funcs#trigger_bitcoin_payment_found_on_next_request"
  get "test_funcs/switch_user"
  
  #match "1337bookstores" => 'pages#bookstores'
  match "bitcoin_payments_index" => "bitcoin_payments#index_bitcoins"
  match "bitcoin_payments_callback" => "bitcoin_payments#trigger_confirmation"
  
  resources :messages


  resources :history_of_prices
  resources :checkout_wallets
  resources :line_items
  resources :products
  get "sales/apply_coupon_to_sale" => "sales#apply_coupon_to_sale"
  resources :sales
  
  resources :bitcoin_payments
  resources :purchases
  
  resources :addresses, :only => [:destroy, :create, :index, :new, :show]
  
  resources :address_errors, :only => [:index]
  post "address_errors/update_them"
  post "address_errors" => "address_errors#update"
  get "admin_pages/discounts"
  get "admin_pages/address_completion_file"
  get "admin_pages/downloader_controls"
  get "admin_pages/download_database"
  get "admin_pages/application_dot_yml"
  get "admin_pages/configuration_tests"

  get "pages/home"
  root :to => 'pages#home'
  
  match "ows" => 'pages#ows'
  match "about" => 'pages#about'
  match "careers" => 'pages#careers'
  match "purchasing" => 'pages#purchasing'
  match "pricing" => 'pages#pricing'
  match "titles" => 'pages#titles'
  match "faq" => 'pages#faq'
  match "most_lovely" => 'pages#most_lovely'
  match "donate" => 'pages#donate'
  match "latest" => 'stories#index'
  match "secure" => 'pages#secure'
  match "mktg" => 'pages#mktg'
  
  
  
  # don't move!  Ordered by usage!
  get "admin_pages/download_shippable"
  
  post "/admin_pages/upload_shippable" => "admin_pages#upload_shippable_file"
  get "admin_pages/upload_shippable"
  
  get "/admin_pages/upload_shipped"
  post "/admin_pages/upload_shipped" => "admin_pages#upload_shipped_file"
  
  
  get "admin_pages/finance"
  get "admin_pages/home"
  get "admin_pages/address_labels"
  get "admin_pages/shipping_control"
  match "admin_pages" => 'admin_pages#home'
  
  
  get "pages/blank"
  get "pages/about"
  get "pages/careers"
  get "pages/purchasing"
  get "pages/pricing"
  get "pages/titles"
  get "pages/faq"
  get "pages/donate"
  get "pages/mktg"
  
  #get "payments/bitcoin"
  
  #post "payments/bitcoin_purchase"
  post "purchases/create"


  # re-enable this garbage when it's time to have users sign in
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end

# populate_users

do_populate_database
