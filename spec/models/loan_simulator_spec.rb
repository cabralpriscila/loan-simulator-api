require 'rails_helper'

RSpec.describe LoanSimulator, type: :model do
  describe 'associations' do
    it { should belong_to(:customer) }
  end

  describe 'validations' do
    it { should validate_presence_of(:requested_amount) }
    it { should validate_presence_of(:term_in_months) }

    it { should validate_numericality_of(:requested_amount).is_greater_than(0) }
    it { should validate_numericality_of(:term_in_months).only_integer.is_greater_than(0) }
    it { should validate_inclusion_of(:term_in_months).in_range(6..96) }

    it { should validate_numericality_of(:interest_rate).is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:monthly_payment).is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:total_payment).is_greater_than(0).allow_nil }
    it { should validate_numericality_of(:total_interest).allow_nil }

    it { should validate_inclusion_of(:status).in_array([ 'pending', 'calculated', 'approved', 'rejected' ]) }
  end

  describe 'custom validations' do
    let(:customer) { create(:customer) }
    let(:simulator) { build(:loan_simulator, customer: customer, requested_amount: amount) }

    context 'when requested amount exceeds maximum allowed' do
      let(:amount) { 1_000_000.01 }

      it 'is invalid' do
        expect(simulator).not_to be_valid
        expect(simulator.errors[:requested_amount]).to include('deve ser menor ou igual a R$ 1.000.000,00')
      end
    end

    context 'when requested amount is below minimum' do
      let(:amount) { 999.99 }

      it 'is invalid' do
        expect(simulator).not_to be_valid
        expect(simulator.errors[:requested_amount]).to include('deve ser maior ou igual a R$ 1.000,00')
      end
    end
  end

  describe 'callbacks' do
    it 'sets status as pending before validation on new records' do
      simulator = build(:loan_simulator, status: nil)
      simulator.valid?
      expect(simulator.status).to eq('pending')
    end
  end

  describe 'scopes' do
    let!(:pending_simulator) { create(:loan_simulator, status: 'pending') }
    let!(:calculated_simulator) { create(:loan_simulator, status: 'calculated') }
    let!(:approved_simulator) { create(:loan_simulator, status: 'approved') }
    let!(:rejected_simulator) { create(:loan_simulator, status: 'rejected') }

    it '.pending returns only pending simulators' do
      expect(described_class.pending).to contain_exactly(pending_simulator)
    end

    it '.calculated returns only calculated simulators' do
      expect(described_class.calculated).to contain_exactly(calculated_simulator)
    end

    it '.approved returns only approved simulators' do
      expect(described_class.approved).to contain_exactly(approved_simulator)
    end

    it '.rejected returns only rejected simulators' do
      expect(described_class.rejected).to contain_exactly(rejected_simulator)
    end
  end
end
