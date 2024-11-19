class LoanCalculationService
  include ApplicationService

  def initialize(loan_simulator)
    @loan_simulator = loan_simulator
  end

  def call
    return failure("Simulação não encontrada") unless loan_simulator.present?
    return failure("Cliente não elegível") unless customer_eligible?

    calculate_loan
  end

  private

  attr_reader :loan_simulator

  def customer_eligible?
    eligibility_result = CustomerEligibilityService.call(loan_simulator.customer)
    eligibility_result.success?
  end

  def calculate_loan
    loan_simulator.interest_rate = calculate_interest_rate
    loan_simulator.monthly_payment = calculate_monthly_payment
    loan_simulator.total_payment = calculate_total_payment
    loan_simulator.total_interest = calculate_total_interest
    loan_simulator.status = "calculated"

    if loan_simulator.save
      success(loan_simulator)
    else
      failure(loan_simulator.errors.full_messages)
    end
  end

  def calculate_interest_rate
    age = loan_simulator.customer.age
    case age
    when 18..25 then 5.0
    when 26..40 then 3.0
    when 41..60 then 2.0
    else 4.0
    end
  end

  def calculate_monthly_payment
    rate = interest_rate_monthly
    amount = loan_simulator.requested_amount
    months = loan_simulator.term_in_months

    numerator = amount * rate * (1 + rate)**months
    denominator = (1 + rate)**months - 1
    payment = numerator / denominator

    Rails.logger.info("Monthly Payment Calculation:
                        rate=#{rate},
                        amount=#{amount},
                        months=#{months},
                        numerator=#{numerator},
                        denominator=#{denominator},
                        payment=#{payment}")
    payment.round(2)
  end

  def calculate_total_payment
    loan_simulator.monthly_payment * loan_simulator.term_in_months
  end

  def calculate_total_interest
    loan_simulator.total_payment - loan_simulator.requested_amount
  end

  def interest_rate_monthly
    loan_simulator.interest_rate / (12 * 100.0)
  end
end
