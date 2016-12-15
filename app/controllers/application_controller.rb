class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  helper_method :current_club
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = exception.message
    redirect_to root_url
  end
  
  def current_club=(club)
    session[:club_id] = club.id
  end
  
  # If i don't find a club from session i return null object
  def current_club
    Club.find_by(ClubCourseID: session[:club_id]) || NullClub.new
  end
  
end
