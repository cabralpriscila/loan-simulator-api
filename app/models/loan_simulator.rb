class LoanSimulator < ApplicationRecord
  STATUSES = [ "pending", "calculated", "approved", "rejected" ].freeze
  MINIMUM_AMOUNT = 1_000
  MAXIMUM_AMOUNT = 1_000_000
  MINIMUM_TERM = 6
  MAXIMUM_TERM = 96

  belongs_to :customer

  validates :requested_amount, presence: true,
                             numericality: { greater_than: 0 }
  validates :term_in_months, presence: true,
                            numericality: { only_integer: true, greater_than: 0 },
                            inclusion: { in: MINIMUM_TERM..MAXIMUM_TERM }

  validates :interest_rate, numericality: { greater_than: 0 }, allow_nil: true
  validates :monthly_payment, numericality: { greater_than: 0 }, allow_nil: true
  validates :total_payment, numericality: { greater_than: 0 }, allow_nil: true
  validates :total_interest, numericality: true, allow_nil: true

  validates :status, inclusion: { in: STATUSES }

  validate :validate_amount_range

  before_validation :set_initial_status, on: :create

  scope :pending, -> { where(status: "pending") }
  scope :calculated, -> { where(status: "calculated") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }

  acts_as_paranoid

  private

  def validate_amount_range
    return unless requested_amount.present?

    if requested_amount < MINIMUM_AMOUNT
      errors.add(:requested_amount, "deve ser maior ou igual a R$ #{MINIMUM_AMOUNT.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1.')},00")
    end

    if requested_amount > MAXIMUM_AMOUNT
      errors.add(:requested_amount, "deve ser menor ou igual a R$ #{MAXIMUM_AMOUNT.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1.')},00")
    end
  end

  def set_initial_status
    self.status ||= "pending"
  end
end
