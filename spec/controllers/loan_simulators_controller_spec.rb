require 'rails_helper'

RSpec.describe Api::V1::LoanSimulatorsController, type: :controller do
  let(:customer) { create(:customer) }
  let!(:loan_simulator) { create(:loan_simulator, customer: customer, status: 'pending') }

  describe 'GET #index' do
    before(:each) do
      LoanSimulator.delete_all
      create_list(:loan_simulator, 25, customer: customer)
    end

    it 'returns paginated results' do
      get :index
      body = JSON.parse(response.body)

      expect(body['loan_simulators'].size).to eq(10)
      expect(body['pagination']['current_page']).to eq(1)
      expect(body['pagination']['total_pages']).to eq(3)
      expect(body['pagination']['total_count']).to eq(25)
    end
  end

  describe 'GET #index' do
    it 'returns paginated results with correct data' do
      get :index
      body = JSON.parse(response.body)

      expect(body['loan_simulators'].size).to eq(10)
      body['loan_simulators'].each do |simulator|
        expect(simulator['interest_rate']).to be_a(String)
      end
    end

    context 'when loan simulator does not exist' do
      it 'returns not found' do
        get :show, params: { id: 'invalid' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        loan_simulator: {
          customer_id: customer.id,
          requested_amount: 50_000,
          term_in_months: 36
        }
      }
    end

    it 'creates and returns the loan simulator' do
      post :create, params: valid_params
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(body['requested_amount']).to eq("R$50.000,00")
      expected_interest_rate = LoanSimulator.last.interest_rate ? "#{LoanSimulator.last.interest_rate}%" : "0.0%"
      expect(body['interest_rate']).to eq(expected_interest_rate)
    end
  end

  describe 'PATCH #update_status' do
    context 'when transition is valid' do
      it 'updates the status of the loan simulator' do
        patch :update_status, params: { id: loan_simulator.id, status: 'calculated' }
        loan_simulator.reload

        expect(response).to have_http_status(:ok)
        expect(loan_simulator.status).to eq('calculated')
      end
    end
  end
end
