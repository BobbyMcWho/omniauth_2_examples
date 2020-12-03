require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'omniauth', github: 'BobbyMcWho/omniauth', branch: 'make-omniauth-use-post-by-default'
  gem 'rails'
  gem 'pry'
end

require 'rails'
require 'action_controller/railtie'
require 'pry'

# Derived from https://github.com/cookpad/omniauth-rails_csrf_protection/blob/master/lib/omniauth/rails_csrf_protection/token_verifier.rb
# This specific implementation has been pared down and should not be taken as the most correct way to do this.
class TokenVerifier
  include ActiveSupport::Configurable
  include ActionController::RequestForgeryProtection

  def call(env)
    @request = ActionDispatch::Request.new(env.dup)
    raise OmniAuth::AuthenticityError unless verified_request?
  end

  private
  attr_reader :request
  delegate :params, :session, to: :request
end

class MyApplication < Rails::Application
  config.session_store :cookie_store, key: '_session'
  config.secret_key_base = '7893aeb3427daf48502ba09ff695da9ceb3c27daf48b0bba09df'
  config.middleware.use OmniAuth::Strategies::Developer
  OmniAuth.config.request_validation_phase = ::TokenVerifier.new

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

MyApplication.routes.draw do
  root to: 'pages#index'
  post '/auth/developer/callback', to: 'pages#callback'
  get '/auth/failure', to: 'pages#failure'
end

run MyApplication
