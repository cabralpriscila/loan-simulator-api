require 'rails_helper'

RSpec.describe CustomerEligibilityService do
  describe '#call' do
    context 'with eligible customer' do
      let(:customer) { build(:customer, birthdate: 30.years.ago, income: 5000) }

      it 'returns success with eligible true' do
        result = described_class.call(customer)
        expect(result.success?).to be true
        expect(result.data[:eligible]).to be true
      end
    end

    context 'with underage customer' do
      let(:customer) { build(:customer, birthdate: 17.years.ago, income: 5000) }

      it 'returns failure with age reason' do
        result = described_class.call(customer)
        expect(result.error[:reasons]).to include("idade mínima não atingida (18 anos)")
      end
    end

    context 'with elderly customer' do
      let(:customer) { build(:customer, birthdate: 66.years.ago, income: 5000) }

      it 'returns failure with age reason' do
        result = described_class.call(customer)
        expect(result.error[:reasons]).to include("idade máxima excedida (65 anos)")
      end
    end

    context 'with insufficient income' do
      let(:customer) { build(:customer, birthdate: 30.years.ago, income: 2999.99) }

      it 'returns failure with income reason' do
        result = described_class.call(customer)
        expect(result.error[:reasons]).to include("renda mínima não atingida (R$ 3.000,00)")
      end
    end

    context 'with multiple ineligibility reasons' do
      let(:customer) { build(:customer, birthdate: 17.years.ago, income: 2000) }

      it 'returns all failure reasons' do
        result = described_class.call(customer)
        expect(result.error[:reasons]).to contain_exactly(
          "idade mínima não atingida (18 anos)",
          "renda mínima não atingida (R$ 3.000,00)"
        )
      end
    end

    context 'with nil customer' do
      it 'returns not found error' do
        result = described_class.call(nil)
        expect(result.error).to eq("Cliente não encontrado")
      end
    end
  end
end
