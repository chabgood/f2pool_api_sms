require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  ruby '2.6.5'

  gem 'httparty'
  gem 'twilio-ruby'
  gem 'pry'
  gem 'actionview'
  gem 'dotenv'
end

require 'dotenv/load'
require 'pry'
require 'httparty'
require 'action_view'
require 'twilio-ruby'

include ActionView::Helpers::NumberHelper

response = HTTParty.get('https://api.f2pool.com/nervos/chabgood').parsed_response
amount = response["value"]
workers_online = response["worker_length_online"]

amount = number_to_human(amount, precision: 4)
client = Twilio::REST::Client.new(ENV["ACCT_SID"], ENV["AUTH_TOKEN"])
client.messages.create(from: ENV["FROM"], to: ENV["TO"], body: "Total: #{amount} \n Workers Online: #{workers_online}")
