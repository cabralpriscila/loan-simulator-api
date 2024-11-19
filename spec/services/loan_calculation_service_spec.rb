require 'rails_helper'

RSpec.describe LoanCalculationService do
  let(:customer) { create(:customer, birthdate: 30.years.ago, income: 5000) }
  let(:loan_simulator) {
 build(:loan_simulator, customer: customer, requested_amount: 50000, term_in_months: 36) }

  describe '#call' do
    context 'when customer is eligible' do
      it 'calculates loan details' do
        result = described_class.call(loan_simulator)
        expect(result).to be_success
        expect(result.data.interest_rate).to eq(3.0)
        expect(result.data.status).to eq('calculated')
      end

      it 'calculates correct monthly payment' do
        result = described_class.call(loan_simulator)
        monthly_payment = result.data.monthly_payment.round(2)
        expected_payment = 1454.06

        expect(monthly_payment).to be_within(0.01).of(expected_payment)
      end

      it 'calculates correct total values' do
        result = described_class.call(loan_simulator)
        expect(result.data.total_payment.round(2)).to be_within(0.01).of(52346.16)
        expect(result.data.total_interest.round(2)).to be_within(0.01).of(2346.16)
      end
    end

    context 'when customer is ineligible' do
      let(:ineligible_customer) { build(:customer, birthdate: 17.years.ago, income: 5000) }
      let(:loan_simulator) { build(:loan_simulator, customer: ineligible_customer) }

      it 'returns failure' do
        result = described_class.call(loan_simulator)
        expect(result).not_to be_success
        expect(result.error).to eq("Cliente não elegível")
      end
    end

    context 'with different age ranges' do
      let(:loan_simulator) { build(:loan_simulator, customer: customer) }

      [
        { age: 20, rate: 5.0 },
        { age: 35, rate: 3.0 },
        { age: 50, rate: 2.0 },
        { age: 65, rate: 4.0 }
      ].each do |age_case|
        it "applies #{age_case[:rate]}% rate for age #{age_case[:age]}" do
          allow(customer).to receive(:age).and_return(age_case[:age])
          result = described_class.call(loan_simulator)
          expect(result.data.interest_rate).to eq(age_case[:rate])
        end
      end
    end
  end
end
