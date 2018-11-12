RailsApp::Application.routes.draw do
  post "items/update_quality" => "items#update_all"
  resources :items

  root :to => "items#index"
end
