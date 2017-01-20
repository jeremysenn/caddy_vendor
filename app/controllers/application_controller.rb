class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  
  helper_method :current_club
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = exception.message
    redirect_to root_url
  end
  
  def current_club=(club)
    session[:club_id] = club.id
  end
  
  def current_club_id
    session[:club_id]
  end
  
  # If i don't find a club from session I return the current_user company's first club.
  def current_club
    Club.find_by(ClubCourseID: session[:club_id]) || current_user.company.clubs.first
  end
  
  protected

  # Permit additional parameters for Devise user
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:time_zone])
  end
  
end
