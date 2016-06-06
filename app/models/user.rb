class User < ActiveRecord::Base
  def mondo
    @mondo ||= Mondo::Client.new(token: token)
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
