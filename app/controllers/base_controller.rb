class BaseController < ApplicationController

  before_filter :check_authentication

  def check_authentication
    unless current_user.present?
      redirect_to "/422.html"
    end
  end

end
