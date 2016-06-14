class TFLTipService
  attr_accessor :user, :overwrite

  def initialize(args = {})
    @user = args.fetch(:user)
  end

  def call
    journey_count = user.journeys.last_month.in_peak_hour.count
    message = "You made #{journey_count} peak hour #{'journey'.pluralize(journey_count)} last month."
    puts "--- #{user.name} ---"
    if journey_count == 0
      puts "\tno message sent, as no journeys."
      return
    else
      puts "\t#{message}"
      user.mondo.create_feed_item(
        title: "Mondo TFL Stats",
        image_url: "https://raw.githubusercontent.com/jameshill/mondo-tfl/master/app/assets/images/mondo_tfl.png",
        body: message,
        url: "https://mondo-tfl.herokuapp.com/tips/peak?#{user.id}",
      )
    end
  end
end
