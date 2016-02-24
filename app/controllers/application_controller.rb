class ApplicationController < ActionController::Base
  protect_from_forgery

	def index
    if(signed_in?)
      redirect_to :controller => "users", :action => "show", :id => current_user.id
    else
		  render './index.html.erb'
    end
	end

  def current_user
    if session.has_key?("id")
      @current_user ||= User.find(session[:id])
    else
      @current_user = nil
    end
  end

  def signed_in?
    !current_user.nil?
  end

  helper_method :current_user
  helper_method :signed_in?
end
