class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /accounts
  # GET /accounts.json
  def index
    respond_to do |format|
      format.html {
        @accounts = current_user.company.caddy_accounts_with_balance
    #    @accounts = current_user.company.accounts
        @balances_total = current_user.company.caddy_accounts_balance_total
    #    @balances_total = current_user.company.accounts_balance_total
      }
      format.csv { 
        accounts = current_user.company.caddy_accounts_with_balance
        send_data accounts.to_csv, filename: "vendor-payables-#{Time.now}.csv" 
      }
    end
    
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { 
          @caddy = @account.caddy
#          redirect_back(fallback_location: root_path) 
           unless @caddy.blank?
            redirect_to @caddy, notice: 'Account was successfully updated.'
           else
             redirect_to root_path, notice: 'Account was successfully updated.'
           end
          }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:MinBalance)
    end
end
