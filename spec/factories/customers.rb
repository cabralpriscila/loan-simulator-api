FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    document_number { DocumentNumberUtils.generate }
    phone { "(#{Faker::Number.number(digits: 2)}) #{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 4)}" }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { "#{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 3)}" }
    birthdate { Faker::Date.between(from: 65.years.ago, to: 18.years.ago) }
    income { Faker::Number.between(from: 3000.0, to: 50000.0).round(2) }
  end
end
