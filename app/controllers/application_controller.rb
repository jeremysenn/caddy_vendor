class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  helper_method :current_course, :current_caddy
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = exception.message
    redirect_to root_url
  end
  
  def current_course=(course)
    session[:course_id] = course.id
  end
  
  def current_course_id
    session[:course_id]
  end
  
  def current_caddy=(caddy)
    session[:caddy_id] = caddy.id
  end
  
  def current_caddy_id
    session[:caddy_id]
  end
  
  # If i don't find a course from session I return the current_user company's first course.
  def current_course
    Course.find_by(ClubCourseID: session[:course_id]) || current_user.company.courses.first
  end
  
  # If current_user is_caddy and i don't find a caddy ID from session I return the current_user caddy ID.
  def current_caddy
    if current_user.is_caddy?
      Caddy.find_by(id: session[:caddy_id]) || current_user.caddy
    end
  end
  
  protected

  # Permit additional parameters for Devise user
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:time_zone, :admin, :active])
  end
  
end
