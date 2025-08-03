class Country < ApplicationRecord
  has_many :profile_countries, dependent: :destroy
  has_many :profiles, through: :profile_countries

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, length: { is: 2 }
  validates :code, format: { with: /\A[A-Z]{2}\z/, message: "must be 2 uppercase letters" }

  before_validation :upcase_code

  scope :ordered, -> { order(:name) }

  def to_s
    name
  end

  private

  def upcase_code
    self.code = code&.upcase
  end
end