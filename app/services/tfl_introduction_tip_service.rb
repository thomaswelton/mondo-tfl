class TFLIntroductionTipService
  attr_accessor :user

  def initialize(args = {})
    @user = args.fetch(:user)
  end

  def call
    journey_count = user.journeys.count
    transaction_count = user.journeys.group_by(&:date).count
    message = "#{journey_count} #{'journey'.pluralize(journey_count)} from #{transaction_count} #{'transaction'.pluralize(transaction_count)} have been added."
    user.mondo.create_feed_item(
      title: "Mondo TFL Stats",
      image_url: "https://raw.githubusercontent.com/jameshill/mondo-tfl/master/app/assets/images/mondo_tfl.png",
      body: message,
      url: "https://mondo-tfl.herokuapp.com/tips/introduction?#{user.id}",
    )
  end
end
