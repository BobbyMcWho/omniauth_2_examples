require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'rails'
  gem 'omniauth', github: 'omniauth/omniauth', branch: '2_0-indev'
  gem 'omniauth-rails_csrf_protection', github: 'bobbymcwho/omniauth-rails_csrf_protection', branch: '2_0_0-rc1_support'
  gem 'pry'
end

require 'rails'
require 'action_controller/railtie'
require 'omniauth'
require 'pry'

class MyApplication < Rails::Application
  config.session_store :cookie_store, key: '_session'
  config.secret_key_base = '7893aeb3427daf48502ba09ff695da9ceb3c27daf48b0bba09df'
  config.middleware.use OmniAuth::Strategies::Developer

  Rails.logger = Logger.new($stdout)
end

class PagesController < ActionController::Base
  def index
    render inline: \
      <<~HTML
        <%= form_tag('/auth/developer', method: 'post') do %>
          <button type='submit'>Login with Developer</button>
        <% end %>

        <form method='post' action='/auth/developer'>
          <button type='submit'>Login with Developer (no Authenticity token)</button>
        </form>
      HTML
  end

  def callback
    render inline: \
    <<~HTML
      <div>Welcome #{request.env['omniauth.auth']['uid']}</div>
    HTML
  end

  def failure
    render inline: \
    <<~HTML
      <div>You reached this due to an error in OmniAuth</div>
      <div>Strategy: #{params['strategy']}</div>
      <div>Message: #{params['message']}</div>
    HTML
  end
end

MyApplication.initialize!

MyApplication.routes.draw do
  root to: 'pages#index'
  post '/auth/developer/callback', to: 'pages#callback'
  get '/auth/failure', to: 'pages#failure'
end

run MyApplication
