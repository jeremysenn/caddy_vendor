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
#    unless report_params[:course_id].blank?
#      @course = Course.where(ClubCourseID: report_params[:course_id]).first
#      @course = current_course.blank? ? current_user.company.courses.first : current_course if @course.blank?
#    else
#      @course = current_course.blank? ? current_user.company.courses.first : current_course
#    end
    respond_to do |format|
      format.html {
#        @transfers = @course.transfers.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, '']).order("#{reports_sort_column} #{reports_sort_direction}").page(params[:page]).per(20)
        @transfers = current_user.company.transfers.where(created_at: @start_date.to_date.in_time_zone(current_user.time_zone).beginning_of_day..@end_date.to_date.in_time_zone(current_user.time_zone).end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, '']).order("created_at DESC")
#        @members = @transfers.map{|t| t.member}.uniq
#        @members = current_user.members.joins(:account).where("accounts.Balance != ?", 0)
        @transfers_total = 0
        @transfers.each do |transfer|
          @transfers_total = @transfers_total + transfer.amount_paid_total unless transfer.amount_paid_total.blank?
        end
#        @transactions = current_user.company.transactions.where(date_time: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day, tran_code: 'CARD', sec_tran_code: ['TFR', 'TFR ']).where.not(tran_code: ['FEE', 'FEE '], amt_auth: [nil]).order("date_time DESC")
#        @transactions_total = 0
#        @transactions.each do |transaction|
#          @transactions_total = @transactions_total + transaction.total unless transaction.total.blank?
#        end
        
#        @members_balance_total = 0
#        @members.each do |member|
#          @members_balance_total = @members_balance_total + member.balance unless member.blank? #or not member.primary?
#        end
      }
      format.csv { 
        @transfers = current_user.company.transfers.where(created_at: @start_date.to_date.in_time_zone(current_user.time_zone).beginning_of_day..@end_date.to_date.in_time_zone(current_user.time_zone).end_of_day, reversed: false).where.not(ez_cash_tran_id: [nil, ''])
        send_data @transfers.to_csv, filename: "transfers-#{Date.today}.csv" 
        }
    end
    
  end
  
  def clear_member_balances
#    unless report_params[:course_id].blank?
#      @course = Course.where(ClubCourseID: report_params[:course_id]).first
#      @course = current_course.blank? ? current_user.company.courses.first : current_course if @course.blank?
#    else
#      @course = current_course.blank? ? current_user.company.courses.first : current_course
#    end
    
    @start_date = current_user.company.date_of_last_cut_transaction.to_s
    @start_date = Date.today.beginning_of_day.to_s if @start_date.blank?
    @end_date = Date.today.end_of_day.to_s
    
    # Need to add 5 hours to because the transaction's date_time in stored as Eastern time
    @transfers = current_user.company.transfers.where(created_at: (@start_date.to_datetime + 5.hours)..@end_date.to_datetime, reversed: false, member_balance_cleared: false).where.not(ez_cash_tran_id: [nil, '']).order("created_at DESC")
    @members = @transfers.map{|t| t.member}.uniq
#    @members = current_user.members.joins(:account).where("accounts.Balance != ?", 0)
    @transfers_total = 0
    @transfers.each do |transfer|
      @transfers_total = @transfers_total + transfer.amount_paid_total unless transfer.amount_paid_total.blank?
    end
    
    # Use current user's time zone since transactions are stored in east coast time
#    @transactions = current_user.company.transactions.where(date_time: @start_date.to_datetime..@end_date.to_datetime, tran_code: 'CARD', sec_tran_code: ['TFR', 'TFR ']).where.not(tran_code: ['FEE', 'FEE '], amt_auth: [nil]).order("date_time DESC")
#    @transactions_total = 0
#    @transactions.each do |transaction|
#      @transactions_total = @transactions_total + transaction.total unless transaction.total.blank?
#    end
    
    @members_balance_total = 0
    @members.each do |member|
      @members_balance_total = @members_balance_total + member.balance unless member.blank? #or not member.primary?
    end
#    unless params[:clearing_member_balances].blank? or @transfers_total.zero?
    unless params[:clearing_member_balances].blank? or @transfers_total.zero?
      current_user.company.perform_one_sided_credit_transaction(@transfers_total)
#      @course.perform_one_sided_credit_transaction(@members_balance_total.abs)
      @transfers.each do |transfer|
        transfer.update_attribute(:member_balance_cleared, true)
      end
      @members.each do |member|
        ClearMemberBalanceWorker.perform_async(member.account_id, current_user.company.account.id, member.balance) unless member.blank? # Clear member's balance with sidekiq background process
      end
      
      flash[:notice] = "Request to clear member balances submitted to EZcash."
      redirect_to reports_path
    end
#    redirect_back(fallback_location: root_path)
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type, :course_id, :clear_member_balances)
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
