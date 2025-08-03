class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_profile_ownership, only: [:edit, :update, :destroy]

  def index
    @profiles = Profile.all.order(:username)
  end

  def show
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user if user_signed_in?

    if @profile.save
      redirect_to @profile, notice: 'Profile was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_url, notice: 'Profile was successfully deleted.'
  end


  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:username, :first_name, :last_name, :bio, :date_of_birth, :is_rider, :is_photographer)
  end

  def check_profile_ownership
    unless @profile.user == current_user || current_user&.admin?
      redirect_to profiles_path, alert: 'You can only edit your own profile.'
    end
  end
end