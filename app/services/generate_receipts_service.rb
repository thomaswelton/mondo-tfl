class GenerateReceiptsService
  attr_accessor :user, :overwrite

  def initialize(args = {})
    @user = args.fetch(:user)
    @overwrite = args[:overwrite] == true
  end

  def attach
    txs = user.transactions
    txs.each do |tx|

      # delete existing first attachment if exists
      if tx.attachments.first && overwrite
        puts 'REMOVING EXISTING IMAGE'
        tx.attachments.first.deregister
      elsif tx.attachments.first
        next
      end

      # get journeys that closest resemble a transaction.
      journeys_for_tx = match(tx.amount.abs)

      if journeys_for_tx.any?

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

        journeys_for_tx.each do |journey|
          journey.mondo_transaction_id = tx.id
          journey.save
        end
      end
    end
  end

  private

  def match(amount)
    date_fares = self.user.journeys.order('date asc').unmatched.group(:date).sum(:fare)
    date, amount = date_fares.find{ |d,v| v == Money.new(amount, :gbp).cents }
    return self.user.journeys.where(date: date).all
  end
end
