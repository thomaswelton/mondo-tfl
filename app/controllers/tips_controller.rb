class TipsController < ApplicationController
  layout 'tips'
  skip_before_filter :authenticate_user!
end
