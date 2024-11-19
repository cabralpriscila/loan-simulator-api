class CustomerEligibilityService
  include ApplicationService

  def initialize(customer)
    @customer = customer
  end

  def call
    return failure("Cliente não encontrado") unless customer.present?

    check_eligibility
  end

  private

  attr_reader :customer

  def check_eligibility
    reasons = []

    reasons << "idade mínima não atingida (18 anos)" unless meets_minimum_age?
    reasons << "idade máxima excedida (65 anos)" unless meets_maximum_age?
    reasons << "renda mínima não atingida (R$ 3.000,00)" unless meets_minimum_income?

    if reasons.empty?
      success(eligible: true)
    else
      failure(reasons: reasons)
    end
  end

  def meets_minimum_age?
    customer.age >= 18
  end

  def meets_maximum_age?
    customer.age <= 65
  end

  def meets_minimum_income?
    customer.income >= 3_000
  end
end
