require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  ruby '2.7.0'

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

coin = ARGV[0] || 'nervos'
response = HTTParty.get("https://api.f2pool.com/#{coin}/chabgood").parsed_response
amount = response["value"]
workers_online = response["worker_length_online"]

if workers_online > 0
  amount = number_to_human(amount, precision: 4)
  client = Twilio::REST::Client.new(ENV["ACCT_SID"], ENV["AUTH_TOKEN"])
  client.messages.create(from: ENV["FROM"], to: ENV["TO"], body: "Total #{coin}: #{amount} \n Workers Online: #{workers_online}")
end