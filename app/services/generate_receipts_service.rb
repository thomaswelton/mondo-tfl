class GenerateReceiptsService
  attr_accessor :user, :overwrite, :mondo

  def initialize(args = {})
    @user = args.fetch(:user)
    @mondo = Mondo::Client.new(token: user.token)
    @overwrite = args[:overwrite] == true
  end

  def call
    matched_tx_count = 0

    txs = mondo.transactions(expand: [:merchant], since: user.last_matched_journey_transaction_id)

    # filter for TFL transactions only as we can't
    # yet scope Mondo requests to a specific merchant
    txs = txs.select { |tx| tx.merchant && tx.merchant.name == 'Transport for London' }

    txs.each do |tx|

      # TODO: probably good idea to degistrer ONLY MondoTFL created attachments
      # will most likely need to search based on the URL and include an identifier
      # in the url.
      tx.attachments.map { |a| a.deregister } if overwrite

      # get journeys that closest resemble a transaction.
      journeys_for_tx = match(tx.amount.abs)

      if journeys_for_tx.any?

        # register the attachment with Mondo
        tx.register_attachment(
          file_url: mondo_image_receipt_url_for(journeys_for_tx),
          file_type: "image/jpg"
        )

        # update all the journeys with the current TX id.
        journeys_for_tx.each do |journey|
          journey.mondo_transaction_id = tx.id
          journey.save
        end

        matched_tx_count += 1
      end
    end

    return matched_tx_count
  end

  private

  def match(amount)
    date_fares = self.user.journeys.order('date asc').unmatched.group(:date).sum(:fare)
    date, amount = date_fares.find { |d,v| v == Money.new(amount, :gbp).cents }
    return self.user.journeys.where(date: date).all
  end

  def image_for(journeys)
    html = ApplicationController.renderer.render('receipts/show', locals: {journeys: journeys}, layout: 'receipts')
    kit = IMGKit.new(html, quality: 100, width: 800, height: 800)
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/receipts.css"
    return kit.to_jpg
  end

  def mondo_image_receipt_url_for(journeys)
    response = RestClient.post('https://api.getmondo.co.uk/attachment/upload', {file_name: "#{SecureRandom.uuid}.jpg", file_type: 'image/jpg'}, {Authorization: "Bearer #{user.token}"})
    response_hash = JSON.parse(response.body)
    private_resource = RestClient::Resource.new(response_hash['upload_url'])
    private_resource.put image_for(journeys), :content_type => 'image/jpg'
    return response_hash['file_url']
  end

  def s3_image_receipt_url_for(journeys)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV['AWS_S3_BUCKET'])
    bucket = s3.create_bucket(bucket: ENV['AWS_S3_BUCKET']) unless bucket.exists?
    object = bucket.object(SecureRandom.uuid)
    object.put(body: image_for(journeys), acl: 'public-read')
    return object.public_url
  end
end
