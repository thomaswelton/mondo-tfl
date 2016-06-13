class PullJourneysService
  attr_accessor :user

  def initialize(args = {})
    @user = args.fetch(:user)
    @tfl = TFL::Client.new(username: user.tfl_username, password: user.tfl_password)
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
      @tfl.journeys(date: search_from)
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
