class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  helper_method :current_course, :current_caddy, :current_member, :current_company
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = exception.message
    redirect_to root_url
  end
  
#  def current_course=(course)
#    session[:course_id] = course.id
#  end
  
#  def current_course_id
#    session[:course_id]
#  end
  
  def current_caddy=(caddy)
    session[:caddy_id] = caddy.id
  end
  
  def current_caddy_id
    session[:caddy_id]
  end
  
  def current_member=(member)
    session[:member_id] = member.id
  end
  
  def current_member_id
    session[:member_id]
  end
  
  def current_company=(company)
    session[:company_id] = company.id
  end
  
  def current_company_id
    session[:company_id]
  end
  
  # If don't find a course from session, return the current_user company's first course.
#  def current_course
#    Course.find_by(ClubCourseID: session[:course_id]) || current_company.courses.first
#  end
  
  # If current_user is_caddy and don't find a caddy ID from session, return the current_user caddy ID.
  def current_caddy
    if current_user.is_caddy?
#      Caddy.find_by(id: session[:caddy_id]) || current_user.caddy
#      Caddy.all.joins(:customer).where("customer.Email = ?", current_user.email).where(ClubCompanyNbr: current_company.id).first || current_user.caddy
#      current_user.caddies.where(ClubCompanyNbr: current_company.id).first
#      current_user.caddies.first
      Caddy.find_by(id: session[:caddy_id]) || current_user.caddies.first
    end
  end
  
  # If current_user is_member and don't find a member ID from session, return the current_user member ID.
#  def current_member
#    if current_user.is_member?
#      Customer.find_by(CustomerID: session[:member_id]) || current_user.member
#    end
#  end
  
  # If don't find a company from session, return the current_user's company ID.
  def current_company
    Company.find_by(CompanyNumber: session[:company_id]) || current_user.company
  end
  
  protected

  # Permit additional parameters for Devise user
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:time_zone, :admin, :active, :pin, :phone])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :role, :phone, :active, :signing_up])
  end
  
  # when a user logs in
  def after_sign_in_path_for(resource_or_scope)
    if current_user.is_member? 
      session[:member_id] = current_user.member.id
      root_path
    elsif current_user.is_caddy? # Set the caddy's caddy ID and company/club ID
      if current_user.phone_verified?
        session[:caddy_id] = current_user.caddy.id unless current_user.caddy.blank?
        session[:company_id] = current_user.company_id
  #        show_caddy_customer_path(current_user.caddy_customer)
        unless current_user.pin.blank?
          caddy_path(current_user.caddy)
        else
          flash[:danger] = 'Please set your PIN.' 
          edit_user_registration_path(current_user)
        end
      else
        root_path
      end
    else
      root_path
    end
  end
  
end
