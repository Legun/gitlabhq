class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  layout "profile"

  def index
    head :forbidden and return
  end

  def create
    @application = Doorkeeper::Application.new(application_params)

    if Doorkeeper.configuration.confirm_application_owner?
      @application.owner = current_user
    end

    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end

  def destroy
    if @application.destroy
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :destroy])
    end

    redirect_to applications_profile_url
  end

  private

  def set_application
    @application = current_user.oauth_applications.find(params[:id])
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render "errors/not_found", layout: "errors", status: 404
  end
end
