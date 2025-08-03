class ProfileCountry < ApplicationRecord
  belongs_to :profile
  belongs_to :country

  validates :profile_id, uniqueness: { scope: :country_id }
end