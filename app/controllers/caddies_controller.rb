class CaddiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_caddy, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  around_action :set_time_zone, if: :current_user


  # GET /caddies
  # GET /caddies.json
  def index
    respond_to do |format|
      format.html {
        unless params[:q].blank?
          caddies = current_user.caddies.joins(:customer).where("customer.NameF like ? OR NameL like ?", params[:q], params[:q]).order("customer.NameL")
        else
          caddies = current_user.caddies.joins(:customer).order("customer.NameL")
        end
        @caddies = caddies.page(params[:page]).per(50)
      }
      format.json {
#        caddies = current_club.caddies
        caddies = current_club.caddies.joins(:customer).where("customer.NameF like ? OR NameL like ?", params[:q], params[:q])
        @caddies = caddies.collect{ |caddy| {id: caddy.id, text: "#{caddy.full_name}"} }
        render json: {results: @caddies}
      }
    end
    
  end

  # GET /caddies/1
  # GET /caddies/1.json
  def show
    @club = @caddy.club
    @transfers = @caddy.transfers
  end

  # GET /caddies/new
  def new
    @caddy = Caddy.new
  end

  # GET /caddies/1/edit
  def edit
    @club = @caddy.club
  end

  # POST /caddies
  # POST /caddies.json
  def create
    @caddy = Caddy.new(caddy_params)

    respond_to do |format|
      if @caddy.save
        format.html { redirect_to @caddy, notice: 'Caddy was successfully created.' }
        format.json { render :show, status: :created, location: @caddy }
      else
        format.html { render :new }
        format.json { render json: @caddy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caddies/1
  # PATCH/PUT /caddies/1.json
  def update
    respond_to do |format|
      if @caddy.update(caddy_params)
        format.html { redirect_to @caddy, notice: 'Caddy was successfully updated.' }
        format.json { render :show, status: :ok, location: @caddy }
      else
        format.html { render :edit }
        format.json { render json: @caddy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /caddies/1
  # DELETE /caddies/1.json
  def destroy
    @caddy.destroy
    respond_to do |format|
      format.html { redirect_to caddies_url, notice: 'Caddy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caddy
      @caddy = Caddy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caddy_params
      params.require(:caddy).permit(:first_name, :last_name, :RankingAcronym, :RankingID, :CheckedIn, :ClubCompanyNbr, :active, customer_attributes:[:PhoneMobile, :NameF, :NameL, :_destroy,:id])
    end
    
    def set_time_zone(&block)
      Time.use_zone(current_user.time_zone, &block)
    end
end
