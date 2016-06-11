class PullJourneysService
  attr_accessor :user

  def initialize(args = {})
    @user = args.fetch(:user)
    @tfl = TFL::Client.new(username: user.tfl_username, password: user.tfl_password)
  end

  def call
    last_journey = user.journeys.last

    if last_journey
      # if they've travelled before, then start the search from 7 days prior
      search_from = last_journey.date - 7.days
    else
      # No journeys, then what was the first transaction on their Mondo card?
      first_transaction = user.transactions.first
      search_from = first_transaction.created - 7.days
    end

    while search_from <= Date.today.at_beginning_of_month.to_date do
      @tfl.journeys(on: search_from)
      search_from = (search_from >> 1).at_beginning_of_month
    end

    @tfl.journeys.each do |j|
      journey = user.journeys.where(from: j.from,
                                      to: j.to,
                                    date: j.date,
                                    time: j.time,
                                    fare: j.fare.cents).first_or_create


    end
    user.journeys
  end
end
