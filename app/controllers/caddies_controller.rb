class CaddiesController < ApplicationController
  before_action :set_caddy, only: [:show, :edit, :update, :destroy]

  # GET /caddies
  # GET /caddies.json
  def index
    @caddies = Caddy.all
  end

  # GET /caddies/1
  # GET /caddies/1.json
  def show
  end

  # GET /caddies/new
  def new
    @caddy = Caddy.new
  end

  # GET /caddies/1/edit
  def edit
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
      params.require(:caddy).permit(:first_name, :last_name, :club_ids => [])
    end
end
