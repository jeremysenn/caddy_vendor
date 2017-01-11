class CaddyPayRatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_caddy_pay_rate, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /caddy_pay_rates
  # GET /caddy_pay_rates.json
  def index
    unless params[:club_id].blank?
      @club = Club.where(ClubCourseID: params[:club_id]).first
      @club = current_club.blank? ? current_user.company.clubs.first : current_club if @club.blank?
    else
      @club = current_club.blank? ? current_user.company.clubs.first : current_club
    end
    @caddy_pay_rates = @club.caddy_pay_rates.sort_by {|cpr| cpr.acronym}
  end

  # GET /caddy_pay_rates/1
  # GET /caddy_pay_rates/1.json
  def show
  end

  # GET /caddy_pay_rates/new
  def new
    @caddy_pay_rate = CaddyPayRate.new
    @club = Club.find(params[:club_id])
  end

  # GET /caddy_pay_rates/1/edit
  def edit
    @club = @caddy_pay_rate.club
  end

  # POST /caddy_pay_rates
  # POST /caddy_pay_rates.json
  def create
    @caddy_pay_rate = CaddyPayRate.new(caddy_pay_rate_params)

    respond_to do |format|
      if @caddy_pay_rate.save
        format.html { redirect_to @caddy_pay_rate, notice: 'CaddyPayRate was successfully created.' }
        format.json { render :show, status: :created, location: @caddy_pay_rate }
      else
        format.html { render :new }
        format.json { render json: @caddy_pay_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caddy_pay_rates/1
  # PATCH/PUT /caddy_pay_rates/1.json
  def update
    respond_to do |format|
      if @caddy_pay_rate.update(caddy_pay_rate_params)
        format.html { redirect_to @caddy_pay_rate, notice: 'CaddyPayRate was successfully updated.' }
        format.json { render :show, status: :ok, location: @caddy_pay_rate }
      else
        format.html { render :edit }
        format.json { render json: @caddy_pay_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /caddy_pay_rates/1
  # DELETE /caddy_pay_rates/1.json
  def destroy
    @caddy_pay_rate.destroy
    respond_to do |format|
      format.html { redirect_to caddy_pay_rates_url, notice: 'CaddyPayRate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caddy_pay_rate
      @caddy_pay_rate = CaddyPayRate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caddy_pay_rate_params
      params.require(:caddy_pay_rate).permit(:ClubCompanyID, :RankingAcronym, :Type, :NbrHoles, :Payrate, :RankingID)
    end
end
