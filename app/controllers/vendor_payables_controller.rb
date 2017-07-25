class VendorPayablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vendor_payable, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /vendor_payables
  # GET /vendor_payables.json
  def index
    respond_to do |format|
      format.html {
        @vendor_payables = current_user.company.caddy_vendor_payables_with_balance
    #    @vendor_payables = current_user.company.vendor_payables
        @balances_total = current_user.company.caddy_vendor_payables_balance_total
    #    @balances_total = current_user.company.vendor_payables_balance_total
      }
      format.csv { 
        vendor_payables = current_user.company.caddy_vendor_payables_with_balance
        send_data vendor_payables.to_csv, filename: "vendor-payables-#{Time.now}.csv" 
      }
    end
    
  end

  # GET /vendor_payables/1
  # GET /vendor_payables/1.json
  def show
    @members = @vendor_payable.members.order(:NameL).page(params[:page]).per(240)
  end

  # GET /vendor_payables/new
  def new
    @vendor_payable = VendorPayable.new
  end

  # GET /vendor_payables/1/edit
  def edit
  end

  # POST /vendor_payables
  # POST /vendor_payables.json
  def create
    @vendor_payable = VendorPayable.new(vendor_payable_params)

    respond_to do |format|
      if @vendor_payable.save
        format.html { redirect_to @vendor_payable, notice: 'VendorPayable was successfully created.' }
        format.json { render :show, status: :created, location: @vendor_payable }
      else
        format.html { render :new }
        format.json { render json: @vendor_payable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendor_payables/1
  # PATCH/PUT /vendor_payables/1.json
  def update
    respond_to do |format|
      if @vendor_payable.update(vendor_payable_params)
        format.html { redirect_to @vendor_payable, notice: 'VendorPayable was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendor_payable }
      else
        format.html { render :edit }
        format.json { render json: @vendor_payable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendor_payables/1
  # DELETE /vendor_payables/1.json
  def destroy
    @vendor_payable.destroy
    respond_to do |format|
      format.html { redirect_to vendor_payables_url, notice: 'VendorPayable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor_payable
      @vendor_payable = VendorPayable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_payable_params
      params.require(:vendor_payable).permit(:VendorPayableName)
    end
end
