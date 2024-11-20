require 'rails_helper'

RSpec.describe Api::V1::LoanSimulatorsController, type: :controller do
  let(:customer) { create(:customer) }
  let!(:loan_simulator) { create(:loan_simulator, customer: customer, status: 'pending') }

  describe 'GET #index' do
    before(:each) do
      LoanSimulator.delete_all
      create_list(:loan_simulator, 25, customer: customer)
    end

    context 'without pagination params' do
      it 'returns the first page with default per_page' do
        get :index
        body = JSON.parse(response.body)

        expect(body['loan_simulators'].size).to eq(10)
        expect(body['pagination']['current_page']).to eq(1)
        expect(body['pagination']['total_pages']).to eq(3)
        expect(body['pagination']['total_count']).to eq(25)
      end
    end

    context 'with pagination params' do
      it 'returns the specified page with custom per_page' do
        get :index, params: { page: 2, per_page: 5 }
        body = JSON.parse(response.body)

        expect(body['loan_simulators'].size).to eq(5)
        expect(body['pagination']['current_page']).to eq(2)
        expect(body['pagination']['total_pages']).to eq(5)
        expect(body['pagination']['total_count']).to eq(25)
      end
    end
  end

  describe 'GET #show' do
    context 'when loan simulator exists' do
      it 'returns the loan simulator' do
        get :show, params: { id: loan_simulator.id }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['id']).to eq(loan_simulator.id)
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

    let(:invalid_params) do
      {
        loan_simulator: {
          customer_id: nil,
          requested_amount: -10,
          term_in_months: 3
        }
      }
    end

    context 'with valid params' do
      it 'creates a new loan simulator' do
        expect {
          post :create, params: valid_params
        }.to change(LoanSimulator, :count).by(1)
      end

      it 'returns the created loan simulator' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['requested_amount']).to eq("50000.0")
      end
    end

    context 'with invalid params' do
      it 'does not create a loan simulator' do
        expect {
          post :create, params: invalid_params
        }.not_to change(LoanSimulator, :count)
      end

      it 'returns unprocessable entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PUT #update' do
    let(:updated_amount) { 60_000 }
    let(:valid_params) do
      { id: loan_simulator.id, loan_simulator: { requested_amount: updated_amount } }
    end

    it 'updates the loan simulator' do
      put :update, params: valid_params
      loan_simulator.reload
      expect(loan_simulator.requested_amount).to eq(updated_amount)
    end
  end

  describe 'DELETE #destroy' do
    let!(:loan_simulator) { create(:loan_simulator) }

    it 'soft deletes the loan simulator' do
      expect {
        delete :destroy, params: { id: loan_simulator.id }
      }.to change { LoanSimulator.without_deleted.count }.by(-1)

      loan_simulator.reload
      expect(loan_simulator.deleted_at).not_to be_nil
    end
  end

  describe 'PATCH #update_status' do
    context 'when the transition is valid' do
      let!(:loan_simulator) { create(:loan_simulator, customer: customer, status: 'pending') }

      it 'updates the status of the loan simulator' do
        Rails.logger.info("LoanSimulator status before: #{loan_simulator.status}")
        patch :update_status, params: { id: loan_simulator.id, status: 'calculated' }
        loan_simulator.reload

        Rails.logger.info("LoanSimulator status after: #{loan_simulator.status}")
        expect(response).to have_http_status(:ok)
        expect(loan_simulator.status).to eq('calculated')
      end
    end

    context 'when the transition is invalid' do
      let!(:loan_simulator) { create(:loan_simulator, customer: customer, status: 'pending') }

      it 'returns an error' do
        patch :update_status, params: { id: loan_simulator.id, status: 'approved' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq("Transition to 'approved' is not allowed from the current state.")
      end
    end
  end
end
