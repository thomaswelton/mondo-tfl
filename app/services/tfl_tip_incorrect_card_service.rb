class TFLTipIncorrectCardService
  attr_accessor :user

  def initialize(args = {})
    @user = args.fetch(:user)
  end

  def call
    journey_count = user.journeys.last_month.in_peak_hour.count
    message = "Do you have a new or replaced Mondo card?"
    puts "--- #{user.name} ---"

    if journey_count == 0
      puts "\tno message sent, as no journeys."
      return
    else
      puts "\t#{message}"
      user.mondo.create_feed_item(
        title: "Mondo TFL",
        image_url: "https://raw.githubusercontent.com/jameshill/mondo-tfl/master/app/assets/images/mondo_tfl.png",
        body: message,
        url: "https://mondo-tfl.herokuapp.com/tips/replacement-card?#{user.id}&current_card=#{user.current_card.last_4_digits}",
      )
    end
  end
end
