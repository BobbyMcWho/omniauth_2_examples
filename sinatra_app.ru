require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'omniauth', github: 'omniauth/omniauth', branch: '2_0-indev'
  gem 'sinatra'
end

require 'sinatra/base'
require 'omniauth'

class MyApplication < Sinatra::Base
  set sessions: true
  use OmniAuth::Strategies::Developer

  get '/' do
    <<~HTML
      <form method='post' action='/auth/developer'>
        <input type="hidden" name="authenticity_token" value='#{request.env["rack.session"]["csrf"]}'>
        <button type='submit'>Login with Developer</button>
      </form>

      <form method='post' action='/auth/developer'>
        <button type='submit'>Login with Developer (no Authenticity token)</button>
      </form>
    HTML
  end

  post '/auth/developer/callback' do
    <<~HTML
      <div>Welcome #{request.env['omniauth.auth']['uid']}</div>
    HTML
  end

  get '/auth/failure' do
    <<~HTML
      <div>You reached this due to an error in OmniAuth</div>
      <div>Strategy: #{params['strategy']}</div>
      <div>Message: #{params['message']}</div>
    HTML
  end
end

run MyApplication
