FactoryBot.define do
  factory :loan_simulator do
    customer
    requested_amount { Faker::Number.between(from: 1_000.0, to: 1_000_000.0).round(2) }
    term_in_months { Faker::Number.between(from: 6, to: 96) }
    interest_rate { Faker::Number.between(from: 1.0, to: 5.0).round(2) }
    status { 'pending' }

    trait :calculated do
      status { 'calculated' }
      monthly_payment { (requested_amount * (1 + interest_rate/100)) / term_in_months }
      total_payment { monthly_payment * term_in_months }
      total_interest { total_payment - requested_amount }
    end

    trait :approved do
      calculated
      status { 'approved' }
    end

    trait :rejected do
      calculated
      status { 'rejected' }
    end
  end
end
