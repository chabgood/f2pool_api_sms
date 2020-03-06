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


class F2Pool
  include HTTParty
  include ActionView::Helpers::NumberHelper
  
  attr_accessor :coin, :headers, :coin_amount, :workers_online, :client, :usd_amount
  def initialize()
    @coin = ARGV[0] || 'nervos'
    @headers = { "X-CMC_PRO_API_KEY" => "#{ENV['API_KEY']}" }
    @coin_amount = 0
    @workers_online = 0
    @usd_amount=0
    initialize_twilio_info
  end


  def initialize_twilio_info
    @account_sid = ENV["ACCT_SID"]
    @auth_token = ENV["AUTH_TOKEN"]
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  end

  def run
    get_f2poool_info
    get_coinmarket_cap_data
    send_sms
  end


  private

  def get_f2poool_info
    response = HTTParty.get("https://api.f2pool.com/#{self.coin}/chabgood").parsed_response
    self.coin_amount = number_to_human(response["value"], precision: 4)
    self.workers_online = response["worker_length_online"]
  end

  def get_coinmarket_cap_data
    data = {'convert' => 'USD', 'amount' => "#{self.coin_amount}", 'symbol'=>"#{self.coin.upcase}"}
    coin_data = HTTParty.get(ENV["API"], query: data, headers: self.headers).parsed_response
    self.usd_amount = number_to_human(coin_data["data"]["quote"]["USD"]["price"],precision: 4)
  end
  
  def send_sms
    if self.workers_online > 0
      client = Twilio::REST::Client.new(ENV["ACCT_SID"], ENV["AUTH_TOKEN"])
      client.messages.create(from: ENV["FROM"], to: ENV["TO"], body: "Total #{self.coin}: #{self.coin_amount} \n Workers Online: #{workers_online} \n USD: $#{self.usd_amount}")
    end
  end
end

f2pool = F2Pool.new
f2pool.run