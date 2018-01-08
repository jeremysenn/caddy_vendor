class CaddyRankDescsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_caddy_rank_desc, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /caddy_rank_descs
  # GET /caddy_rank_descs.json
  def index
    unless params[:course_id].blank?
      @course = Course.where(ClubCourseID: params[:course_id]).first
      @course = current_course.blank? ? current_user.company.courses.first : current_course if @course.blank?
    else
      @course = current_course.blank? ? current_user.company.courses.first : current_course
    end
    @caddy_rank_descs = @course.caddy_rank_descs.order(:RankingAcronym)
  end

  # GET /caddy_rank_descs/1
  # GET /caddy_rank_descs/1.json
  def show
    @caddies = @caddy_rank_desc.caddies
    @caddy_pay_rates = @caddy_rank_desc.caddy_pay_rates
  end

  # GET /caddy_rank_descs/new
  def new
    @caddy_rank_desc = CaddyRankDesc.new
    @course = Course.find(params[:course_id])
  end

  # GET /caddy_rank_descs/1/edit
  def edit
    @course = @caddy_rank_desc.course
  end

  # POST /caddy_rank_descs
  # POST /caddy_rank_descs.json
  def create
    @caddy_rank_desc = CaddyRankDesc.new(caddy_rank_desc_params)

    respond_to do |format|
      if @caddy_rank_desc.save
        format.html { redirect_to @caddy_rank_desc, notice: 'CaddyRankDesc was successfully created.' }
        format.json { render :show, status: :created, location: @caddy_rank_desc }
      else
        format.html { render :new }
        format.json { render json: @caddy_rank_desc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caddy_rank_descs/1
  # PATCH/PUT /caddy_rank_descs/1.json
  def update
    respond_to do |format|
      if @caddy_rank_desc.update(caddy_rank_desc_params)
        format.html { redirect_to @caddy_rank_desc, notice: 'CaddyRankDesc was successfully updated.' }
        format.json { render :show, status: :ok, location: @caddy_rank_desc }
      else
        format.html { render :edit }
        format.json { render json: @caddy_rank_desc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /caddy_rank_descs/1
  # DELETE /caddy_rank_descs/1.json
  def destroy
    @caddy_rank_desc.destroy
    respond_to do |format|
      format.html { redirect_to caddy_rank_descs_url, notice: 'CaddyRankDesc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caddy_rank_desc
      @caddy_rank_desc = CaddyRankDesc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caddy_rank_desc_params
      params.require(:caddy_rank_desc).permit(:ClubCompanyID, :RankingAcronym, :RankingDescription, :course_id)
    end
end
