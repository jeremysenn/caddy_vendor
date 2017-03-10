class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /customers
  # GET /customers.json
  def index
    respond_to do |format|
      format.html {
        unless params[:q].blank?
          members = current_user.members.where("NameF like ? OR NameL like ?", params[:q], params[:q])
          members = current_user.members.joins(:account).where("accounts.ActNbr like ?", params[:q]) if members.blank?
        else
          unless params[:balances].blank?
            members = current_user.members.joins(:account).where("accounts.Balance != ?", 0).order(:NameL)
          else
            members = current_user.members.order(:NameL)
          end
            
        end
        @members = members.page(params[:page]).per(50)
      }
      format.json {
        members = current_user.members.where("NameF like ? OR NameL like ?", params[:q], params[:q])
        members = current_user.members.joins(:account).where("accounts.ActNbr like ?", params[:q]) if members.blank?
        @members = members.collect{ |member| {id: member.id, text: "#{member.full_name}"} }
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
    @customer.build_account
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    
    respond_to do |format|
      if @customer.save
        format.html { 
          unless customer_params[:ParentCustID].blank?
            redirect_back fallback_location: @customer, notice: 'Family member was successfully created.'
          else
            redirect_to @customer, notice: 'Member was successfully created.' 
          end
          }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:ParentCustID, :CompanyNumber, :Active, :GroupID, :NameF, :NameL, :NameS, :PhoneMobile,
        account_attributes:[:CompanyNumber, :Balance, :MinBalance, :Active, :CustomerID, :ActNbr, :_destroy,:id])
    end
end
