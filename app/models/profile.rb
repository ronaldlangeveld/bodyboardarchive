class Profile < ApplicationRecord
  belongs_to :user, optional: true
  has_many :profile_countries, dependent: :destroy
  has_many :countries, through: :profile_countries
  
  validates :username, presence: true, uniqueness: true
  validates :username, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "can only contain letters, numbers, underscores, and hyphens" }
  validates :username, length: { minimum: 3, maximum: 30 }
  
  validate :must_be_rider_or_photographer

  scope :unclaimed, -> { where(user: nil) }
  scope :claimed, -> { where.not(user: nil) }

  def claimed?
    user.present?
  end

  def unclaimed?
    user.blank?
  end
  
  private
  
  def must_be_rider_or_photographer
    unless is_rider || is_photographer
      errors.add(:base, "Profile must be either a rider or photographer (or both)")
    end
  end
end
