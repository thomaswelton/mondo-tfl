class ReceiptsController < ApplicationController
  def show
    tfl = TFL::Client.new(username: current_user.tfl_username, password: current_user.tfl_password)
    @journeys = tfl.journeys(date: Date.parse(params[:date]))
    respond_to do |format|
      format.html
      format.jpg do
        kit = IMGKit.new(render_to_string(formats: :html), quality: 100, width: 800, height: 800)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/receipts.css"
        send_data(kit.to_jpg, type:  "image/jpeg", disposition: 'inline')
      end
    end
  end

  private

  def journeys
    @journeys
  end
  helper_method :journeys
end
