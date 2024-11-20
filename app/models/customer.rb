class Customer < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :document_number, presence: true, uniqueness: true, document_number: true
  validates :phone, format: { with: /\A\(\d{2}\)\s\d{4,5}-\d{4}\z/ }, allow_blank: true
  validates :zip_code, format: { with: /\A\d{5}-\d{3}\z/ }, allow_blank: true
  validates :birthdate, presence: true
  validates :income, presence: true, numericality: { greater_than: 0 }

  validate :birthdate_cannot_be_in_future
  validate :must_be_of_legal_age

  scope :by_deletion_status, ->(include_deleted) {
    include_deleted ? with_deleted : without_deleted
  }

  has_many :loan_simulators, dependent: :destroy

  def age
    return nil unless birthdate.present?
    ((Time.zone.now - birthdate.to_time) / 1.year.seconds).floor
  end

  def eligible_for_loan?
    return false unless age.present? && income.present?

    income >= 3000.0 && age.between?(18, 65)
  end

  private

  def birthdate_cannot_be_in_future
    return unless birthdate.present?
    return unless birthdate.to_date > Date.current

    errors.add(:birthdate, "não pode estar no futuro")
  end

  def must_be_of_legal_age
    return unless birthdate.present?
    return if age >= 18

    errors.add(:birthdate, "deve ser maior de 18 anos")
  end
end
