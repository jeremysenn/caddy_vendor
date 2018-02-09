class WelcomeController < ApplicationController
  def index
    if user_signed_in? and current_user.is_caddy? and not params[:company_id].blank?
      session[:company_id] = params[:company_id]
#      session[:course_id] = current_caddy.course.id
    end
  end
end
