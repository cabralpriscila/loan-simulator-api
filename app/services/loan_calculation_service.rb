class LoanCalculationService
  def self.call(loan_simulator)
    new(loan_simulator).calculate
  end

  def initialize(loan_simulator)
    @loan_simulator = loan_simulator
  end

  def calculate
    return ServiceResult.failure("Cliente não elegível") unless eligible?

    @loan_simulator.interest_rate = calculate_interest_rate
    @loan_simulator.monthly_payment = calculate_monthly_payment
    @loan_simulator.total_payment = calculate_total_payment
    @loan_simulator.total_interest = @loan_simulator.total_payment - @loan_simulator.requested_amount
    @loan_simulator.status = "calculated"

    if @loan_simulator.save
      ServiceResult.success(@loan_simulator)
    else
      ServiceResult.failure(@loan_simulator.errors.full_messages.join(", "))
    end
  end

  private

  def eligible?
    @loan_simulator.customer.age >= 18
  end

  def calculate_interest_rate
    case @loan_simulator.customer.age
    when 18..29 then 5.0
    when 30..44 then 3.0
    when 45..60 then 2.0
    else 4.0
    end
  end

  def calculate_monthly_payment
    r = @loan_simulator.interest_rate / 100 / 12
    n = @loan_simulator.term_in_months
    p = @loan_simulator.requested_amount

    (p * r * (1 + r)**n) / ((1 + r)**n - 1)
  end

  def calculate_total_payment
    @loan_simulator.monthly_payment * @loan_simulator.term_in_months
  end
end
