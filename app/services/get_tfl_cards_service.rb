class GetTFLCardsService
  attr_accessor :user

  def initialize(args = {})
    @user = args.fetch(:user)
    @tfl ||= TFL::Client.new(username: user.tfl_username, password: user.tfl_password)
  end

  def call
    begin
      @tfl.cards.each do |tfl_card|
        user.cards.where(last_4_digits: tfl_card.last_4_digits,
                                expiry: tfl_card.expiry,
                               network: tfl_card.network).first_or_create!
      end
    rescue => e
      raise InvalidUsernameOrPasswordError, e
    end
  end
end

class InvalidUsernameOrPasswordError < StandardError
end
