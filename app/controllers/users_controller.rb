class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :pin_verification, :verify_phone]
  load_and_authorize_resource
#  around_action :set_time_zone, if: :current_user


  # GET /users
  # GET /users.json
  def index
#    unless params[:q].blank?
#      @query_string = "%#{params[:q]}%"
#      @users = current_user.company.users.where("email like ?", @query_string)
#    else
#      @users = current_user.company.users
#    end
    @users = current_user.company.users
    @admin_users = @users.where(role: 'admin')
    @member_users = @users.where(role: 'member')
    @caddy_users = @users.where(role: 'caddy')
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_admin_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_admin_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def pin_verification
    respond_to do |format|
      format.html { 
        pin = params[:pin]
        # Make sure that pin matches up with User's saved pin
        if pin == @user.pin.to_s
          response = @user.ezcash_send_mms_cust_barcode_web_service_call
          if response == true
            flash[:notice] = "A text message has been sent to you with your payment QR Code."
            redirect_back(fallback_location: root_path)
          else
            flash[:error] = "There was a problem sending your QR Code."
            redirect_back(fallback_location: root_path)
          end
        else
          flash[:error] = "There was a problem with your PIN."
          redirect_back(fallback_location: root_path)
        end
        }
    end
  end
  
  # GET /users/1/verify_phone
  def verify_phone
    respond_to do |format|
      format.html { 
        code = params[:verification_code].to_i
        Rails.logger.debug "User code: #{@user.verification_code}"
        if code == @user.verification_code
          # Make sure that code matches up with User's verification code
          @user.update_attribute(:verification_code, nil)
          flash[:notice] = "Phone verified."
          redirect_to root_path
        else
          flash[:error] = "Code is incorrect."
          redirect_to root_path
        end
        }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:company_id, :email, :password, :time_zone, :admin, :active, :role, :pin, :phone)
    end
    
end
