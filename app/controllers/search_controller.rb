class SearchController < ApplicationController
  def index
    unless user_signed_in?
      redirect_to new_user_session_path, alert: 'Please sign in to search for profiles.'
      return
    end

    @profiles = Profile.where(user: nil, sixty_forty_import: true)
                      .order(:first_name, :last_name, :username)
  end

  def claim
    unless user_signed_in?
      redirect_to new_user_session_path, alert: 'Please sign in to claim a profile.'
      return
    end

    @profile = Profile.find(params[:id])
    
    if @profile.user.present?
      redirect_to search_path, alert: 'This profile has already been claimed.'
      return
    end

    @profile.update!(user: current_user)
    redirect_to edit_profile_path(@profile), notice: 'Profile successfully claimed! Please update your information.'
  end
end
