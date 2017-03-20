class CaddiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_caddy, only: [:show, :edit, :update, :pay, :destroy]
  load_and_authorize_resource
  around_action :set_time_zone, if: :current_user


  # GET /caddies
  # GET /caddies.json
  def index
    respond_to do |format|
      unless params[:club_id].blank?
        @club = Club.where(ClubCourseID: params[:club_id]).first
        @club = current_club.blank? ? current_user.company.clubs.first : current_club if @club.blank?
      else
        @club = current_club.blank? ? current_user.company.clubs.first : current_club
      end
      format.html {
        unless params[:q].blank?
          @query_string = "%#{params[:q]}%"
          caddies = @club.caddies.joins(:customer).where("customer.NameF like ? OR NameL like ?", @query_string, @query_string).order("customer.NameL")
        else
          caddies = @club.caddies.joins(:customer).order("customer.NameL")
        end
        unless params[:caddy_rank_desc_id].blank?
          @caddies = caddies.where(RankingID: params[:caddy_rank_desc_id]).page(params[:page]).per(50)
        else
          @caddies = caddies.page(params[:page]).per(50)
        end
      }
      format.json {
        @query_string = "%#{params[:q]}%"
#        caddies = current_club.caddies
        caddies = @club.caddies.joins(:customer).where("customer.NameF like ? OR NameL like ?", @query_string, @query_string)
        @caddies = caddies.collect{ |caddy| {id: caddy.id, text: "#{caddy.full_name}"} }
        render json: {results: @caddies}
      }
    end
    
  end

  # GET /caddies/1
  # GET /caddies/1.json
  def show
    @club = @caddy.club
#    @transfers = @caddy.transfers
    @transfers = @caddy.account_transfers.order('created_at DESC') unless @caddy.account_transfers.blank?
    @text_messages = @caddy.sms_messages
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
  
  def send_group_text_message
    respond_to do |format|
      format.html {
        unless params[:q].blank?
          @query_string = "%#{params[:q]}%"
          caddies = current_user.caddies.active.joins(:customer).where("customer.NameF like ? OR NameL like ?", @query_string, @query_string).order("customer.NameL")
        else
          caddies = current_user.caddies.active.joins(:customer).order("customer.NameL")
        end
        unless params[:caddy_rank_desc_id].blank?
          @caddies = caddies.where(RankingID: params[:caddy_rank_desc_id])
        else
          @caddies = caddies
        end
        @message_body = params[:message_body]
        @caddies.each do |caddy|
          caddy.send_sms_notification(@message_body)
        end
        redirect_back fallback_location: customers_path, notice: 'Text message sent to caddies.'
      }
    end
  end
  
  def pay
    member = Customer.where(CustomerID: params[:member_id]).first
    amount = params[:amount].to_f.abs unless params[:amount].blank?
    note = params[:note]
    unless member.blank?
      Transfer.create(club_id: @caddy.club.id, from_account_id: member.account_id, to_account_id: @caddy.account.id, customer_id: member.id, amount: amount, note: note)
    else
      club = @caddy.club
      transaction_id = club.perform_one_sided_credit_transaction(amount)
      Rails.logger.debug "*********************************Club transaction ID: #{transaction_id}"
      Transfer.create(club_id: club.id, from_account_id: club.account.id, to_account_id: @caddy.account.id, amount: amount, note: note)
    end
    redirect_back fallback_location: @caddy, notice: 'Caddy payment submitted.'
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
