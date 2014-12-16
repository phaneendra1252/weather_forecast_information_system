class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, notice: 'Access denied.'
  end
  helper :all # include all helpers, all the time

  private

    def set_imd_states
      @imd_states = ImdState.all
    end

end
