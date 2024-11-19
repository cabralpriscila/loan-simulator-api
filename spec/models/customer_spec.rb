require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    subject { build(:customer) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:document_number) }
    it { should validate_presence_of(:birthdate) }
    it { should validate_presence_of(:income) }

    context 'when validating email' do
      it { should allow_value('john@mail.com').for(:email) }
      it { should_not allow_value('invalid_email').for(:email) }
    end

    context 'when validating document_number' do
      it { should allow_value('12345678909').for(:document_number) }
      it { should_not allow_value('123456789').for(:document_number) }
      it { should_not allow_value('1234567890a').for(:document_number) }
    end

    context 'when validating phone' do
      it { should allow_value('(11) 99999-9999').for(:phone) }
      it { should_not allow_value('999999999').for(:phone) }
    end

    context 'when validating zip_code' do
      it { should allow_value('12345-678').for(:zip_code) }
      it { should_not allow_value('12345678').for(:zip_code) }
    end

    it { should validate_numericality_of(:income).is_greater_than(0) }

    describe 'birthdate validations' do
      context 'when birthdate is in the future' do
        before { subject.birthdate = 1.day.from_now }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:birthdate]).to include('não pode estar no futuro')
        end
      end

      context 'when customer is under 18' do
        before { subject.birthdate = 17.years.ago }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:birthdate]).to include('deve ser maior de 18 anos')
        end
      end
    end
  end

  describe '#age' do
    let(:customer) { build(:customer, birthdate: 30.years.ago) }

    it 'returns the correct age' do
      expect(customer.age).to eq(30)
    end
  end

  describe '#eligible_for_loan?' do
    subject { build(:customer, income: income, birthdate: birthdate) }

    context 'when customer meets all criteria' do
      let(:income) { 3000 }
      let(:birthdate) { 30.years.ago }

      it { is_expected.to be_eligible_for_loan }
    end

    context 'when income is too low' do
      let(:income) { 2999.99 }
      let(:birthdate) { 30.years.ago }

      it { is_expected.not_to be_eligible_for_loan }
    end

    context 'when customer is too young' do
      let(:income) { 3000 }
      let(:birthdate) { 17.years.ago }

      it { is_expected.not_to be_eligible_for_loan }
    end

    context 'when customer is too old' do
      let(:income) { 3000 }
      let(:birthdate) { 66.years.ago }

      it { is_expected.not_to be_eligible_for_loan }
    end
  end
end
