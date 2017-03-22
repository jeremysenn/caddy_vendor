class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  helper_method :current_course
  
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
  
  # If i don't find a course from session I return the current_user company's first course.
  def current_course
    Course.find_by(ClubCourseID: session[:course_id]) || current_user.company.courses.first
  end
  
  protected

  # Permit additional parameters for Devise user
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:time_zone, :admin, :active])
  end
  
end
