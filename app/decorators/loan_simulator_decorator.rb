class LoanSimulatorDecorator < SimpleDelegator
  include ActionView::Helpers::NumberHelper

  def monthly_payment
    number_to_currency(super, unit: "R$", separator: ",", delimiter: ".")
  end

  def total_payment
    number_to_currency(super, unit: "R$", separator: ",", delimiter: ".")
  end

  def total_interest
    number_to_currency(super, unit: "R$", separator: ",", delimiter: ".")
  end

  def interest_rate
    number_to_percentage(super, precision: 2)
  end

  def requested_amount
    number_to_currency(super, unit: "R$", separator: ",", delimiter: ".")
  end
end
