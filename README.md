Demo apps to demonstrate the changes I made in [this branch](https://github.com/omniauth/omniauth/compare/master...BobbyMcWho:make-omniauth-use-post-by-default).  
`$ rackup sinatra_app.ru`  
`$ rackup rails_app.ru`  

By default the failure handler does not route to `/auth/failure` in development. If you would like to route to that:  
`$ RACK_ENV=production rackup sinatra_app.ru`  
`$ RAILS_ENV=production RACK_ENV=production rackup rails_app.ru`  
