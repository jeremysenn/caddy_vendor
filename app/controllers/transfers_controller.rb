class TransfersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transfer, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  helper_method :transfers_sort_column, :transfers_sort_direction

  # GET /transfers
  # GET /transfers.json
  def index
    unless params[:club_id].blank?
      @club = Club.where(ClubCourseID: params[:club_id]).first
      @club = current_club.blank? ? current_user.company.clubs.first : current_club if @club.blank?
    else
      @club = current_club.blank? ? current_user.company.clubs.first : current_club
    end
    respond_to do |format|
      format.html {
        @transfers = @club.transfers.order("#{transfers_sort_column} #{transfers_sort_direction}").page(params[:page]).per(20)
      }
      format.csv { 
        @transfers = @club.transfers.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day, reversed: false)
        send_data @transfers.to_csv, filename: "transfers-#{Date.today}.csv" 
        }
    end
  end

  # GET /transfers/1
  # GET /transfers/1.json
  def show
    @from = @transfer.customer
    @to = @transfer.to_customer
  end

  # GET /transfers/new
  def new
    @transfer = Transfer.new
  end

  # GET /transfers/1/edit
  def edit
  end

  # POST /transfers
  # POST /transfers.json
  def create
    @transfer = Transfer.new(transfer_params)

    respond_to do |format|
      if @transfer.save
#        format.html { redirect_to @transfer, notice: 'Transfer was successfully created.' }
#        format.html { redirect_to :back, notice: 'Transfer was successfully created.' }
        format.html { 
          unless @transfer.ez_cash_tran_id.blank?
            redirect_back fallback_location: root_path, notice: 'Transfer was successfully created.' 
          else
            redirect_back fallback_location: root_path, alert: 'There was a problem connecting to EZcash.' 
          end
          }
        format.json { render :show, status: :created, location: @transfer }
      else
        format.html { 
#          render :new 
          redirect_back fallback_location: root_path, alert: 'There was a problem connecting to EZcash.'
          }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transfers/1
  # PATCH/PUT /transfers/1.json
  def update
    respond_to do |format|
      if @transfer.update(transfer_params)
        format.html { redirect_to @transfer, notice: 'Transfer was successfully updated.' }
        format.json { render :show, status: :ok, location: @transfer }
      else
        format.html { render :edit }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfers/1
  # DELETE /transfers/1.json
  def destroy
    @transfer.destroy
    respond_to do |format|
      format.html { redirect_to transfers_url, notice: 'Transfer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = Transfer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfer_params
      params.require(:transfer).permit(:amount, :caddy_fee, :caddy_tip, :to_account, :from_account, :fee, :customer_id, :player_id, :reversed)
    end
    
    ### Secure the transfers sort direction ###
    def transfers_sort_direction
      %w[asc desc].include?(params[:transfers_direction]) ?  params[:transfers_direction] : "desc"
    end

    ### Secure the transfers sort column name ###
    def transfers_sort_column
      ["ez_cash_tran_id", "created_at", "from_account_id", "to_account_id", "caddy_fee_cents", "caddy_tip_cents", "amount_cents", "fee_cents", "fee_to_account_id"].include?(params[:transfers_column]) ? params[:transfers_column] : "created_at"
    end
end
