class UsersController < ApplicationController
  def update
    current_user.attributes = user_params
    if current_user.save
      redirect_to root_path
    else
      render 'sessions/new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:tfl_username, :tfl_password)
  end
end