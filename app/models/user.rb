class User < ActiveRecord::Base
  attr_encrypted :tfl_username, key: ENV['ATTR_SECRET_KEY']
  attr_encrypted :tfl_password, key: ENV['ATTR_SECRET_KEY']

  has_many :journeys
  has_many :cards

  def mondo
    @mondo ||= Mondo::Client.new(token: token)
  end

  def tfl
    @tfl ||= TFL::Client.new(username: tfl_username, password: tfl_password)
  end

   def transactions
    # BECAUSE JUST A DEMO request all transaction
    transactions = mondo.transactions

    # BECAUSE JUST A DEMO USING RUBY SELECT
    # No doubt many ways to increase performance, including caching transactions
    # locally and then using perfomanting querying languages.
    transactions.select!{|tx| tx.merchant && tx.merchant.name == 'Transport for London'}
    return transactions
  end

  def request_new_token
    url = OmniAuth::Strategies::Mondo.default_options.client_options.token_url
    response = RestClient.post url, {'grant_type' => 'refresh_token', 'refresh_token' => refresh_token, 'client_id' => ENV['MONDO_CLIENT_ID'], 'client_secret' => ENV['MONDO_SECRET']}
    response_hash = JSON.parse(response.body)

    self.token         = response_hash['access_token']
    self.refresh_token = response_hash['refresh_token']
    self.expires_at    = DateTime.now + response_hash["expires_in"].to_i.seconds
    self.save

    @mondo = nil
  end

  class << self
    def from_omniauth(auth_hash)
      user = where(uid: auth_hash['uid'], provider: auth_hash['provider']).first_or_create
      user.name          = auth_hash['info']['name']
      user.token         = auth_hash['info']['token']
      user.refresh_token = auth_hash['info']['refresh_token']
      user.expires_at    = auth_hash['info']['expires_at']
      user.save!
      user
    end
  end
end
