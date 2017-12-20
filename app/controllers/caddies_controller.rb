class CaddiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_caddy, only: [:show, :edit, :update, :pay, :barcode, :destroy]
  load_and_authorize_resource
  around_action :set_time_zone, if: :current_user

  helper_method :caddies_sort_column, :caddies_sort_direction

  # GET /caddies
  # GET /caddies.json
  def index
    respond_to do |format|
      unless params[:course_id].blank?
        @course = Course.where(ClubCourseID: params[:course_id]).first
        @course = current_course.blank? ? current_user.company.courses.first : current_course if @course.blank?
      else
        @course = current_course.blank? ? current_user.company.courses.first : current_course
      end
      format.html {
        unless params[:q].blank?
          @query_string = "%#{params[:q]}%"
          caddies = @course.caddies.joins(:customer).where("customer.NameF like ? OR NameL like ? OR customer.PhoneMobile like ?", @query_string, @query_string, @query_string) #.order("customer.NameL")
        else
          unless params[:balances].blank?
            caddies = Kaminari.paginate_array(current_user.company.caddies_with_balance)
          else
            caddies = @course.caddies.joins(:customer) #.order("customer.NameL")
          end
        end
        unless params[:caddy_rank_desc_id].blank?
          if params[:balances].blank?
            caddies = caddies.where(RankingID: params[:caddy_rank_desc_id]).order("#{caddies_sort_column} #{caddies_sort_direction}")
            @caddies = caddies.page(params[:page]).per(20)
          else
            caddies = caddies.where(RankingID: params[:caddy_rank_desc_id]).order("#{caddies_sort_column} #{caddies_sort_direction}")
            @caddies = caddies.page(params[:page]).per(20)
          end
        else
          if params[:balances].blank?
            caddies = caddies.order("#{caddies_sort_column} #{caddies_sort_direction}")
            @caddies = caddies.page(params[:page]).per(20)
          else
            @caddies = caddies.page(params[:page]).per(20)
          end
        end
        @all_caddies = caddies
      }
      format.json {
        @query_string = "%#{params[:q]}%"
#        caddies = current_course.caddies
        caddies = @course.caddies.joins(:customer).where("customer.NameF like ? OR NameL like ?", @query_string, @query_string)
        @caddies = caddies.collect{ |caddy| {id: caddy.id, text: "#{caddy.full_name}"} }
        render json: {results: @caddies}
      }
    end
    
  end

  # GET /caddies/1
  # GET /caddies/1.json
  def show
    @course = @caddy.course
#    @transfers = @caddy.transfers
    # Get caddy account transfers, filtered by company_id
    @transfers = @caddy.account_transfers.where(company_id: current_user.company_id).order('created_at DESC') unless @caddy.account_transfers.blank?
    @text_messages = @caddy.sms_messages.reverse
    # Get caddy account withdrawal transactions, filtered by company_id
    @withdrawal_transactions = @caddy.customer.transactions.where(DevCompanyNbr: current_user.company_id).withdrawals.last(20).reverse
  end

  # GET /caddies/new
  def new
    @caddy = Caddy.new
  end

  # GET /caddies/1/edit
  def edit
    @course = @caddy.course
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
  
#  def send_group_text_message
#    respond_to do |format|
#      format.html {
#        unless params[:q].blank?
#          @query_string = "%#{params[:q]}%"
#          caddies = current_user.caddies.active.joins(:customer).where("customer.NameF like ? OR NameL like ?", @query_string, @query_string).order("customer.NameL")
#        else
#          unless params[:balances].blank?
#            caddies = current_user.company.caddies_with_balance
#          else
#            caddies = current_user.caddies.active.joins(:customer).order("customer.NameL")
#          end
#        end
#        unless params[:caddy_rank_desc_id].blank?
#          @caddies = caddies.where(RankingID: params[:caddy_rank_desc_id])
#        else
#          @caddies = caddies
#        end
#        @message_body = params[:message_body]
#        @caddies.each do |caddy|
#          caddy.send_sms_notification(@message_body)
#        end
#        redirect_back fallback_location: customers_path, notice: 'Text message sent to caddies.'
#      }
#    end
#  end

  def send_group_text_message
    respond_to do |format|
      format.html {
        @message_body = params[:message_body]
        unless params[:caddy_ids].blank?
          params[:caddy_ids].each do |caddy_id|
            caddy = Caddy.where(id: caddy_id).first
            caddy.send_sms_notification(@message_body) unless caddy.blank?
          end
          redirect_back fallback_location: customers_path, notice: 'Text message sent to caddies.'
        else
          redirect_back fallback_location: customers_path, alert: 'You must select at least one caddy to text message.'
        end
      }
    end
  end
  
  def pay
    member = Customer.where(CustomerID: params[:member_id]).first
    amount = params[:amount].to_f.abs unless params[:amount].blank?
    note = params[:note]
    unless member.blank?
      Transfer.create(company_id: current_user.company.id, from_account_id: member.account_id, to_account_id: @caddy.account.id, customer_id: member.id, amount: amount, note: note)
    else
      course = @caddy.course
      transaction_id = course.perform_one_sided_credit_transaction(amount)
      Rails.logger.debug "*********************************Club transaction ID: #{transaction_id}"
      Transfer.create(company_id: current_user.company.id, from_account_id: current_user.company.account.id, to_account_id: @caddy.account.id, amount: amount, note: note, club_credit_transaction_id: transaction_id)
    end
    redirect_back fallback_location: @caddy, notice: 'Caddy payment submitted.'
  end
  
  # GET /caddies/1/barcode
  # GET /caddies/1/barcode.json
  def barcode
    @base64_barcode_string = Transaction.ezcash_get_barcode_png_web_service_call(@caddy.CustomerID, current_user.company_id, 5)
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
    
    ### Secure the caddies sort direction ###
    def caddies_sort_direction
      %w[asc desc].include?(params[:caddies_direction]) ?  params[:caddies_direction] : "asc"
    end

    ### Secure the caddies sort column name ###
    def caddies_sort_column
      ["customer.NameL", "customer.NameF"].include?(params[:caddies_column]) ? params[:caddies_column] : "customer.NameF"
    end
end
