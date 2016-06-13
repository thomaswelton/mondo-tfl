class PullJourneysService
  attr_accessor :user

  def initialize(args = {})
    @user = args.fetch(:user)
    @tfl = TFL::Client.new(username: user.tfl_username, password: user.tfl_password)
    @current_card = @tfl.cards.find{|c| c.last_4_digits == user.current_card.last_4_digits &&
                                        c.network == user.current_card.network &&
                                        c.expiry == user.current_card.expiry }
  end

  def call
    last_journey = user.journeys.last

    if last_journey
      # if they've travelled before, then start the search from the beginning of that month
      search_from = last_journey.date.at_beginning_of_month
    else
      # No journeys, then what was the first transaction on their Mondo card?
      first_transaction = user.transactions.first
      search_from = first_transaction.created.at_beginning_of_month
    end

    while search_from <= Date.today.at_beginning_of_month.to_date do
      @tfl.journeys(date: search_from, card: @current_card)
      search_from = (search_from >> 1).at_beginning_of_month
    end

    @tfl.journeys.each do |j|
      journey = user.journeys.where(from: j.from,
                                      to: j.to,
                                    date: j.date,
                                    time: j.time,
                                    fare: j.fare.cents,
                           tapped_in_mod: time_to_mod(j.tapped_in_at),
                          tapped_out_mod: time_to_mod(j.tapped_out_at),
                                 card_id: user.current_card.id).first_or_create
    end
    user.journeys
  end

  private

  def time_to_mod(time_string)
    return nil if time_string.nil?
    hour, minute = time_string.split(':')
    (hour.to_i * 60) + minute.to_i
  end
end
