class BalanceLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_balance_log, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /balance_logs
  # GET /balance_logs.json
  def index
    @start_date = balance_log_params[:start_date] ||= Date.today.to_s
    @end_date = balance_log_params[:end_date] ||= Date.today.to_s
    @balance_logs = current_company.balance_logs.order("EventDateTime DESC").where(EventDateTime: @start_date.to_date.in_time_zone(current_user.time_zone).beginning_of_day..@end_date.to_date.in_time_zone(current_user.time_zone).end_of_day)
  end

  # GET /balance_logs/1
  # GET /balance_logs/1.json
  def show
    transfers = current_user.company.transfers.where(created_at: @balance_log.StartDateTime.to_date.in_time_zone(current_user.time_zone).beginning_of_day..@balance_log.EndDateTime.to_date.in_time_zone(current_user.time_zone).end_of_day).where.not(ez_cash_tran_id: [nil, ''])
    @transfers_total_amount = 0
    transfers.each do |transfer|
      @transfers_total_amount = @transfers_total_amount + transfer.amount_billed
    end
    respond_to do |format|
      format.html {
        @all_transfers = transfers
        @transfers = transfers.order("created_at DESC").page(params[:page]).per(20)
      }
      format.csv { 
        @transfers = transfers
        send_data @transfers.order("created_at DESC").to_csv, filename: "transfers-#{@start_date}-#{@end_date}.csv" 
        }
    end
  end

  # GET /balance_logs/new
  def new
    @balance_log = BalanceLog.new
    @end_date = params[:end_date] ||= Date.today.to_s
    @last_balance_log = current_company.balance_logs.last
    unless @last_balance_log.blank?
      @start_date = @last_balance_log.EventDateTime
    else
      @start_date = Date.today.to_s
    end
    
    transfers = current_user.company.transfers.where(created_at: @start_date.to_date.in_time_zone(current_user.time_zone).beginning_of_day..@end_date.to_date.in_time_zone(current_user.time_zone).end_of_day).where.not(ez_cash_tran_id: [nil, ''])
    @transfers_total_amount = 0
    transfers.each do |transfer|
      @transfers_total_amount = @transfers_total_amount + transfer.amount_billed
    end
    
    respond_to do |format|
      format.html {
        @all_transfers = transfers
        @transfers = transfers.order("created_at DESC").page(params[:page]).per(20)
      }
      format.csv { 
        @transfers = transfers
        send_data @transfers.order("created_at DESC").to_csv, filename: "transfers-#{@start_date}-#{@end_date}.csv" 
        }
    end
    
  end

  # GET /balance_logs/1/edit
  def edit
  end

  # POST /balance_logs
  # POST /balance_logs.json
  def create
    @balance_log = BalanceLog.new(balance_log_params)

    respond_to do |format|
      if @balance_log.save
        format.html { redirect_to @balance_log, notice: 'BalanceLog was successfully created.' }
        format.json { render :show, status: :created, location: @balance_log }
      else
        format.html { render :new }
        format.json { render json: @balance_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /balance_logs/1
  # PATCH/PUT /balance_logs/1.json
  def update
    respond_to do |format|
      if @balance_log.update(balance_log_params)
        format.html { redirect_to @balance_log, notice: 'BalanceLog was successfully updated.' }
        format.json { render :show, status: :ok, location: @balance_log }
      else
        format.html { render :edit }
        format.json { render json: @balance_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /balance_logs/1
  # DELETE /balance_logs/1.json
  def destroy
    @balance_log.destroy
    respond_to do |format|
      format.html { redirect_to balance_logs_url, notice: 'BalanceLog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_balance_log
      @balance_log = BalanceLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def balance_log_params
      params.fetch(:balance_log, {}).permit(:start_date, :end_date, :EventID, :EventDateTime, :StartDateTime, :EndDateTime, :StartTranID, :EndTranID, :TotalAmount, :CompanyNumber)
    end
end
