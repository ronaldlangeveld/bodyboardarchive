class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :profile, dependent: :destroy

  def self.from_omniauth(auth)
    return nil unless auth&.info&.email
    
    where(email: auth.info.email).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def match_to_profile!
    ProfileMatcherService.match_user_to_profile(self)
  end

  def has_bodyboarding_profile?
    profile.present?
  end
end
