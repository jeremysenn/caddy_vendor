class CaddyRatingsController < ApplicationController
#  before_action :authenticate_user!
  before_action :set_caddy_rating, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  # GET /caddy_ratings
  # GET /caddy_ratings.json
  def index
    unless params[:caddy_id].blank?
      @caddy = Caddy.where(id: params[:caddy_id]).first
      @caddy_ratings = @caddy.blank? ? current_user.company.caddy_ratings.order(created_at: :desc) : @caddy.caddy_ratings.order(created_at: :desc)
    else
      @caddy_ratings = current_user.company.caddy_ratings.order(created_at: :desc)
    end
  end
  
  def show
    @player = @caddy_rating.player
  end
  
  # GET /caddy_ratings/new
  def new
    @player = Player.where(id: params[:player_id]).first
#    @caddy = Caddy.where(id: params[:caddy_id]).first
    if @player.caddy_rating.blank?
      @caddy = @player.caddy unless @player.blank?
      @caddy_rating = CaddyRating.new
    else
      redirect_to root_path, notice: 'Caddy has already been rated for this round.'
    end
    
  end
  
  # POST /caddy_ratings
  # POST /caddy_ratings.json
  def create
    @caddy_rating = CaddyRating.new(caddy_rating_params)
    
    respond_to do |format|
      if @caddy_rating.save
        format.html { redirect_to @caddy_rating.caddy, notice: 'CaddyRating was successfully created.' }
        format.json { render :show, status: :created, location: @caddy_rating }
      else
        format.html { render :new }
        format.json { render json: @caddy_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caddy_rank_descs/1
  # PATCH/PUT /caddy_rank_descs/1.json
  def update
    respond_to do |format|
      if @caddy_rating.update(caddy_rank_desc_params)
        format.html { redirect_to @caddy_rating, notice: 'CaddyRating was successfully updated.' }
        format.json { render :show, status: :ok, location: @caddy_rating }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @caddy_rating.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
#  def update
#    @rating = Rating.find(params[:id])
#    @comment = @rating.comment
#    if @rating.update_attributes(score: params[:score])
#      respond_to do |format|
#        format.js
#      end
#    end
#  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caddy_rating
      @caddy_rating = CaddyRating.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caddy_rating_params
      params.require(:caddy_rating).permit(:score, :comment, :caddy_id, :user_id, :player_id, :appearance_score, :enthusiasm_score)
    end
end
