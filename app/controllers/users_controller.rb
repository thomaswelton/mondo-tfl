class UsersController < ApplicationController
  def update
    current_user.attributes = user_params

    GetTFLCardsService.new(user: current_user).call

    if current_user.save
      redirect_to root_path
    else
      render 'sessions/new'
    end

  rescue InvalidUsernameOrPasswordError => e
    flash.now[:error] = e
    render 'sessions/new'
  end

  private

  def user_params
    params.require(:user).permit(:tfl_username, :tfl_password, :current_card_id)
  end
end
