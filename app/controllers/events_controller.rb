class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:index, :new, :create, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @start_date = event_params[:start_date] ||= Date.today.to_s
    @end_date = event_params[:end_date] ||= Date.today.to_s
    unless event_params[:course_id].blank?
      session[:course_id] = event_params[:course_id]
      @course = Course.where(ClubCourseID: event_params[:course_id]).first
      @course = current_course.blank? ? current_user.company.courses.first : current_course if @course.blank?
    else
      @course = current_course.blank? ? current_user.company.courses.first : current_course
    end
    @events = current_course.events.where(start: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).order("start DESC")
#    @events = current_course.events
#    session[:course_id] = params[:course_id] unless params[:course_id].blank?
#    unless current_course.blank?
#      @events = current_course.events
#    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
    @event.players.build
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
#    @event.save
#    if params[:pay]
#      redirect_to @event
#    end

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
        format.js {
          if params[:pay]
            redirect_to @event
          end
        }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @event.update(event_params)
    if params[:pay]
#      redirect_to @event, notice: 'Select Member and Caddy for Payment'
      redirect_to @event
    end
#    respond_to do |format|
#      if @event.update(event_params)
#        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
#        format.json { render :show, status: :ok, location: @event }
#      else
#        format.html { render :edit }
#        format.json { render json: @event.errors, status: :unprocessable_entity }
#      end
#    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
#    respond_to do |format|
#      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
#      format.json { head :no_content }
#    end
  end
  
  def calendar
    session[:course_id] = params[:course_id] unless params[:course_id].blank?
    unless event_params[:course_id].blank?
      session[:course_id] = event_params[:course_id]
      @course = Course.where(ClubCourseID: event_params[:course_id]).first
      @course = current_course.blank? ? current_user.company.courses.first : current_course if @course.blank?
    else
      @course = current_course.blank? ? current_user.company.courses.first : current_course
    end
    @events = @course.events
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.fetch(:event, {}).permit(:title, :date_range, :start, :end, :color, :size, :round, :status, :notes, :course_id, :start_date, :end_date, :course_id,
        players_attributes:[:event_id, :member_id, :caddy_id, :caddy_type, :fee, :tip, :round, :status, :_destroy, :id, :note])
    end
end
