class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :clear_account_balance, :show_caddy]
  load_and_authorize_resource

  # GET /customers
  # GET /customers.json
  def index
    respond_to do |format|
      format.html {
        unless params[:q].blank?
          @query_string = "%#{params[:q]}%"
          members = current_user.company.members.where("NameF like ? OR NameL like ?", @query_string, @query_string)
          members = current_user.company.members.joins(:accounts).where("accounts.ActNbr like ?", @query_string) if members.blank?
        else
          unless params[:balances].blank?
            members = current_user.company.members_with_balance
          else
            members = current_user.company.members
          end
        end
        @members = members.order(:NameL).page(params[:page]).per(50)
        @all_members = members
      }
      format.json {
        @query_string = "%#{params[:q]}%"
        members = current_user.members.where("NameF like ? OR NameL like ?", @query_string, @query_string)
        members = current_user.members.joins(:accounts).where("accounts.ActNbr like ?", @query_string) if members.blank?
        @members = members.order(:NameL).collect{ |member| {id: member.id, text: "#{member.full_name}"} }
        render json: {results: @members}
      }
    end
    
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @add_on_members = Customer.where(ParentCustID: @customer.id)
    @transfers = @customer.transfers.order(created_at: :desc)
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    @customer.accounts.build
#    @type = params[:type]
    @customer.type = params[:type]
#    @customer.course_id = params[:course_id]
    if @customer.type == "caddy"
      # Get the default minimum balance for this company's caddies
      @default_minimum_balance_row = CompanyActDefaultMinBal.where(CompanyNumber: current_user.company.id, AccountTypeID: 6).first
    end
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    # Check to see if existing customer already exists, first searching by phone, then by email.
    @customer = Customer.find_by(PhoneMobile: customer_params[:PhoneMobile])
    if @customer.blank? and not customer_params[:Email].blank?
      @customer = Customer.find_by(Email: customer_params[:Email])
    end
#    @customer.type = "#{@customer.GroupID == 13 ? 'caddy' : 'member' }"
    if @customer.blank?
      # If customer does not yet exist, create a new one
      @customer = Customer.new(customer_params)
    else
      # Pass company_id virtual attribute in case customer's company is different from current user
      @customer.company_id = customer_params[:company_id]
    end
    
    respond_to do |format|
      if @customer.accounts.where(CompanyNumber: current_user.company_id).blank? and @customer.save
        # No existing customer accounts for this company and successfully saved
        format.html { 
          unless customer_params[:ParentCustID].blank?
            redirect_back fallback_location: @customer, notice: 'Family member was successfully created.'
          else
            unless current_user.is_caddy?
              if @customer.member?
                redirect_to @customer, notice: 'Member was successfully created.' 
              elsif @customer.caddy?
                redirect_to @customer.caddies.last, notice: 'Caddy was successfully created.'
#                redirect_to edit_caddy_path(@customer.caddies.last), notice: 'Caddy was successfully created.'
#                redirect_to caddies_path, notice: 'Caddy was successfully created.'
              else
                redirect_to root_path, notice: 'Customer was successfully created.'
              end
            else
              flash[:notice] = 'Club successfully added.' 
              redirect_to root_path
            end
          end
          }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { 
          render :new 
          }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # GET /customers/1/clear_account_balance
  def clear_account_balance
    respond_to do |format|
      if @customer.clear_account_balance
        format.html { redirect_back fallback_location: @customer, notice: "Member's account balance was successfully cleared." }
      else
        format.html { redirect_back fallback_location: @customer, alert: "There was a problem clearing this member's account balance." }
      end
    end
  end
  
  # GET /customers/clear_all_account_balances
  def clear_all_account_balances
    respond_to do |format|
      format.html {
        unless params[:balances].blank?
          members = current_user.company.members_with_balance
          members.each do |member|
            member.clear_account_balance
          end
          redirect_back fallback_location: customers_path, notice: "Request to clear member account balances has been submitted."
        else
          redirect_back fallback_location: customers_path, alert: "No member account balances to clear."
        end
      }
    end
    
  end
  
  # GET /customers/1/show_caddy
  def show_caddy
    @club_account = @customer.club_account(current_company.id)
    # Get caddy account transfers, filtered by company_id
    @transfers = Transfer.where(to_account_id: @club_account.id).or(Transfer.where(from_account_id: @club_account.id)).where(company_id: current_company.id).order('created_at DESC')
    # Get caddy account withdrawal transactions, filtered by company_id
    @withdrawal_transactions = @club_account.withdrawals.last(20).reverse
    @balance = @club_account.Balance
    @minimum_balance = @club_account.MinBalance
    @available_balance = @balance - @minimum_balance
    @text_messages = []
    @customer.caddies.each do |caddy|
      @text_messages = @text_messages + caddy.sms_messages
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:ParentCustID, :CompanyNumber, :Active, :GroupID, :NameF, :NameL, :NameS, :PhoneMobile, :Email, 
        :LangID, :Registration_Source, :Registration_Source_ext, :course_id, :type, :company_id,
        accounts_attributes:[:CompanyNumber, :Balance, :MinBalance, :Active, :CustomerID, :ActNbr, :ActTypeID, :BankActNbr, :RoutingNbr, :_destroy,:id])
    end
end
