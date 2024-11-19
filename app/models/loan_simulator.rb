class LoanSimulation < ApplicationRecord
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

  acts_as_paranoid
end
