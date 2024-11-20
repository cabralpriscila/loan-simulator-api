class LoanSimulator < ApplicationRecord
  include AASM

  aasm column: "status" do
    state :pending, initial: true
    state :calculated
    state :approved
    state :rejected

    event :calculate do
      transitions from: :pending, to: :calculated
    end

    event :approve do
      transitions from: :calculated, to: :approved
    end

    event :reject do
      transitions from: :calculated, to: :rejected
    end
  end

  MINIMUM_AMOUNT = 1_000.00
  MAXIMUM_AMOUNT = 1_000_000.00

  belongs_to :customer

  validates :requested_amount, presence: true, numericality: { greater_than: 0 }
  validates :term_in_months, inclusion: { in: 6..96 }

  validates :interest_rate, numericality: { greater_than: 0 }, allow_nil: true
  validates :monthly_payment, numericality: { greater_than: 0 }, allow_nil: true
  validates :total_payment, numericality: { greater_than: 0 }, allow_nil: true
  validates :total_interest, numericality: true, allow_nil: true

  validate :validate_amount_range

  acts_as_paranoid

  private

  def validate_amount_range
    return unless requested_amount.present?

    if requested_amount < MINIMUM_AMOUNT
      errors.add(:requested_amount, "deve ser maior ou igual a R$ #{MINIMUM_AMOUNT.to_i},00")
    end

    if requested_amount > MAXIMUM_AMOUNT
      errors.add(:requested_amount, "deve ser menor ou igual a R$ #{MAXIMUM_AMOUNT.to_i},00")
    end
  end
end
