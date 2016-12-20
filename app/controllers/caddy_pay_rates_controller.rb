class CaddyPayRatesController < ApplicationController
  before_action :authenticate_user!
#  before_action :set_caddy_pay_rate, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /caddy_pay_rates
  # GET /caddy_pay_rates.json
  def index
    @caddy_pay_rates = current_user.caddy_pay_rates
  end

  # GET /caddy_pay_rates/1
  # GET /caddy_pay_rates/1.json
  def show
    # Look up caddy pay rate by composite of club ID and ranking acronym
    @caddy_pay_rate = CaddyPayRate.where(ClubCompanyID: params[:id], RankingAcronym: params[:ranking_acronym]).first
  end

  # GET /caddy_pay_rates/new
  def new
    @caddy_pay_rate = CaddyPayRate.new
  end

  # GET /caddy_pay_rates/1/edit
  def edit
    # Look up caddy pay rate by composite of club ID and ranking acronym
    @caddy_pay_rate = CaddyPayRate.where(ClubCompanyID: params[:id], RankingAcronym: params[:ranking_acronym]).first
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
    @caddy_pay_rate = CaddyPayRate.where(ClubCompanyID: params[:id], RankingAcronym: caddy_pay_rate_params[:RankingAcronym]).first
    respond_to do |format|
      if @caddy_pay_rate.update(caddy_pay_rate_params)
#        format.html { redirect_to @caddy_pay_rate, notice: 'CaddyPayRate was successfully updated.' }
        format.html { redirect_to caddy_pay_rate_path(@caddy_pay_rate.id, ranking_acronym: @caddy_pay_rate.RankingAcronym), notice: 'CaddyPayRate was successfully updated.' }
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
#    def set_caddy_pay_rate
#      @caddy_pay_rate = CaddyPayRate.find(params[:id])
#    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caddy_pay_rate_params
      params.require(:caddy_pay_rate).permit(:ClubCompanyID, :RankingAcronym, :Type, :NbrHoles, :Payrate)
    end
end
