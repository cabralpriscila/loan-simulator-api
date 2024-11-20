require 'rails_helper'

RSpec.describe LoanSimulator, type: :model do
  let(:customer) { create(:customer) }
  let(:simulator) { build(:loan_simulator, customer: customer, requested_amount: 10_000, term_in_months: 12) }

  before(:each) do
    LoanSimulator.delete_all
  end
  
  describe 'associations' do
    it { should belong_to(:customer) }
  end

  describe 'validations' do
    it { should validate_presence_of(:requested_amount) }

    it 'validates that :term_in_months is included in the valid range' do
      simulator.term_in_months = nil
      expect(simulator).not_to be_valid
      expect(simulator.errors[:term_in_months]).to include('is not included in the list')
    end

    it 'validates inclusion of :term_in_months in range 6..96' do
      simulator.term_in_months = 5
      expect(simulator).not_to be_valid
      expect(simulator.errors[:term_in_months]).to include('is not included in the list')

      simulator.term_in_months = 97
      expect(simulator).not_to be_valid
      expect(simulator.errors[:term_in_months]).to include('is not included in the list')

      simulator.term_in_months = 12
      expect(simulator).to be_valid
    end

    it 'validates amount range for :requested_amount' do
      simulator.requested_amount = 500
      expect(simulator).not_to be_valid
      expect(simulator.errors[:requested_amount]).to include('deve ser maior ou igual a R$ 1000,00')

      simulator.requested_amount = 1_500_000
      expect(simulator).not_to be_valid
      expect(simulator.errors[:requested_amount]).to include('deve ser menor ou igual a R$ 1000000,00')
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

  describe 'AASM states' do
    it 'has initial state as pending' do
      expect(simulator.aasm.current_state).to eq(:pending)
    end

    it 'transitions from pending to calculated' do
      simulator.calculate!
      expect(simulator.aasm.current_state).to eq(:calculated)
    end

    it 'transitions from calculated to approved' do
      simulator.aasm.current_state = :calculated
      simulator.approve!
      expect(simulator.aasm.current_state).to eq(:approved)
    end

    it 'transitions from calculated to rejected' do
      simulator.aasm.current_state = :calculated
      simulator.reject!
      expect(simulator.aasm.current_state).to eq(:rejected)
    end

    it 'does not allow transition from pending to approved directly' do
      expect { simulator.approve! }.to raise_error(AASM::InvalidTransition)
    end
  end
end
