class ReportsController < ApplicationController
  before_action :authenticate_user!
#  before_action :set_report, only: [:show, :edit, :update, :destroy]
#  load_and_authorize_resource

  helper_method :reports_sort_column, :reports_sort_direction
  
  # GET /reports
  # GET /reports.json
  def index
    @start_date = report_params[:start_date] ||= Date.today.to_s
    @end_date = report_params[:end_date] ||= Date.today.to_s
    unless report_params[:club_id].blank?
      @club = Club.where(ClubCourseID: report_params[:club_id]).first
      @club = current_club.blank? ? current_user.company.clubs.first : current_club if @club.blank?
    else
      @club = current_club.blank? ? current_user.company.clubs.first : current_club
    end
    respond_to do |format|
      format.html {
#        @transfers = @club.transfers.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, '']).order("#{reports_sort_column} #{reports_sort_direction}").page(params[:page]).per(20)
        @transfers = @club.transfers.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, '']).order("created_at DESC")
        @transfers_total = 0
        @transfers.each do |transfer|
          @transfers_total = @transfers_total + transfer.total unless transfer.total.blank?
        end
        @transactions = current_user.company.transactions.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, tran_code: 'CARD', sec_tran_code: ['TFR', 'TFR ']).where.not(tran_code: ['FEE', 'FEE '], amt_auth: [nil, 0]).order("date_time DESC")
        @transactions_total = 0
        @transactions.each do |transaction|
          @transactions_total = @transactions_total + transaction.total unless transaction.total.blank?
        end
        @members_balance_total = 0
        @transfers.each do |transfer|
          @members_balance_total = @members_balance_total + transfer.customer.account.Balance unless transfer.customer.blank? or transfer.customer.account.blank?
        end
      }
      format.csv { 
        @transfers = @club.transfers.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, ''])
        send_data @transfers.to_csv, filename: "transfers-#{Date.today}.csv" 
        }
    end
    
  end
  
  def clear_member_balances
    @start_date = report_params[:start_date] ||= Date.today.to_s
    @end_date = report_params[:end_date] ||= Date.today.to_s
    @club = Club.where(ClubCourseID: report_params[:club_id]).first
    @transfers = @club.transfers.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, '']).order("created_at DESC")
    @transfers.each do |transfer|
      unless transfer.customer.blank? or transfer.customer.account.blank?
        if transfer.customer.account.ezcash_clear_balance_transaction_web_service_call 
          flash[:notice] = "Member balances successfully cleared by EZcash."
        else
          flash[:alert] = "There was a problem clearing member balances with EZcash."
        end
      end
    end
    redirect_back(fallback_location: root_path)
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type, :club_id)
    end
    
    ### Secure the reports sort direction ###
    def reports_sort_direction
      %w[asc desc].include?(params[:reports_direction]) ?  params[:reports_direction] : "desc"
    end

    ### Secure the reports sort column name ###
    def reports_sort_column
      ["ez_cash_tran_id", "created_at", "from_account_id", "to_account_id", "caddy_fee_cents", "caddy_tip_cents", "amount_cents", "fee_cents", "fee_to_account_id"].include?(params[:reports_column]) ? params[:reports_column] : "created_at"
    end
end
