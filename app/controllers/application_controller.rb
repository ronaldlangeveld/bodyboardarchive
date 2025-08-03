class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def after_sign_in_path_for(resource)
    # Try to match user to existing profiles after sign in
    if resource.is_a?(User) && resource.profile.blank?
      matched_profiles = ProfileMatcherService.find_potential_matches(resource, 5)
      if matched_profiles.any?
        flash[:notice] = "We found #{matched_profiles.length == 1 ? 'a profile' : "#{matched_profiles.length} profiles"} that might be yours! Please search and claim if it's you."
      else
        flash[:alert] = "We couldn't find a matching profile. Search through all profiles or setup a new one."
      end
      return search_path
    end
    
    super
  end
end
