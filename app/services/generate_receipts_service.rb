class GenerateReceiptsService
  attr_accessor :user, :overwrite

  def initialize(args = {})
    @user = args.fetch(:user)
    @overwrite = args[:overwrite] == true
    @tfl = TFL::Client.new(username: user.tfl_username, password: user.tfl_password)
  end

  def attach
    txs = user.transactions
    txs.each do |tx|
      next if tx.settled.blank?

      # delete existing first attachment if exists
      if tx.attachments.first && overwrite
        puts 'REMOVING EXISTING IMAGE'
        tx.attachments.first.deregister
      elsif tx.attachments.first
        next
      end

      puts "-----------------"
      puts "MONDO TRANSACTION"
      puts "#{tx.id} | #{tx.settled} | #{tx.amount.abs}"

      # get journeys that closest resemble a transaction.
      journeys_for_tx = find_journeys(@tfl, tx.settled, tx.amount.abs)

      puts "\tJOURNEYS"
      journeys_for_tx.each do |journey|
        puts "\t #{journey.from}-#{journey.to}, #{journey.date} | #{journey.fare}"
      end

      if journeys_for_tx
        # generate JPG receipt of journeys
        html = ApplicationController.renderer.render('receipts/show', locals: {journeys: journeys_for_tx}, layout: 'receipts')
        kit = IMGKit.new(html, quality: 100, width: 800, height: 800)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/receipts.css"

        # puts 'upload jpg to s3'
        s3 = Aws::S3::Resource.new

        bucket = s3.bucket(ENV['AWS_S3_BUCKET'])
        bucket = s3.create_bucket(bucket: ENV['AWS_S3_BUCKET']) unless bucket.exists?
        object = bucket.object(SecureRandom.uuid)
        object.put(body: kit.to_jpg, acl: 'public-read')

        # puts "register image into mondo"
        # puts object.public_url

        tx.register_attachment(
          file_url: object.public_url,
          file_type: "image/jpg"
        )
      end
    end
  end

  private

  def find_journeys(tfl, date, amount)
    @search_limit ||= date - 7 # search up to one week ago

    journeys = tfl.journeys(on: date)
    total    = tfl.total(on: date)

    amount_doesnt_match = Money.new(total, :gbp) != Money.new(amount, :gbp)

    if journeys.empty? || amount_doesnt_match
      if date < @search_limit
        @search_limit = nil
        return []
      else
        return find_journeys(tfl, date - 1, amount)
      end
    else
      @search_limit = nil
      return journeys
    end
  end
end
