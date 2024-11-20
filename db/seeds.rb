require_relative '../app/utils/document_number_utils'

LoanSimulator.delete_all
Customer.delete_all

puts 'Criando clientes...'
customers = []
5.times do |i|
  customers << Customer.create!(
    name: "Cliente #{i + 1}",
    email: "cliente#{i + 1}@teste.com",
    document_number: DocumentNumberUtils.generate,
    phone: "(#{Faker::Number.number(digits: 2)}) #{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 4)}",
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: "#{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 3)}",
    birthdate: Faker::Date.birthday(min_age: 18, max_age: 65),
    income: Faker::Number.decimal(l_digits: 4, r_digits: 2)
  )
end

puts 'Criando simulações de empréstimos...'
customers.each do |customer|
  3.times do
    LoanSimulator.create!(
      customer: customer,
      requested_amount: Faker::Number.between(from: 10_000, to: 100_000),
      term_in_months: Faker::Number.between(from: 12, to: 60),
      interest_rate: Faker::Number.between(from: 2.0, to: 5.0),
      monthly_payment: nil,
      total_payment: nil,
      total_interest: nil,
      status: 'pending'
    )
  end
end

puts '🚀🚀🚀🚀🚀🚀'
