require 'rails_helper'

RSpec.describe Api::V1::CustomersController, type: :controller do
  describe 'GET #index' do
    before(:each) do
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE customers RESTART IDENTITY CASCADE")
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE loan_simulators RESTART IDENTITY CASCADE")
    end

    context 'when checking if the database is clean' do
      it 'makes sure the database is clean' do
        expect(Customer.count).to eq(0)
        expect(Customer.with_deleted.count).to eq(0)
      end
    end

    context 'with include_deleted param' do
      let!(:active_customers) { create_list(:customer, 10) }
      let!(:deleted_customer) { create(:customer).tap(&:destroy) }

      it 'returns all customers including deleted ones' do
        expect(Customer.with_deleted.count).to eq(11)
        get :index, params: { include_deleted: true }
        body = JSON.parse(response.body)
        expect(body['customers'].size).to eq(11)
      end
    end

    context 'without include_deleted param' do
      let!(:active_customers) { create_list(:customer, 10) }

      it 'returns only active customers' do
        get :index
        body = JSON.parse(response.body)
        expect(body['customers'].size).to eq(10)
      end
    end
  end


  describe 'GET #show' do
    let!(:customer) { create(:customer) }

    context 'when customer exists' do
      it 'returns a successful response' do
        get :show, params: { id: customer.id }
        expect(response).to be_successful
      end

      it 'returns the correct customer' do
        get :show, params: { id: customer.id }
        expect(JSON.parse(response.body)['id']).to eq(customer.id)
      end
    end

    context 'when customer does not exist' do
      it 'returns not found status' do
        get :show, params: { id: 'invalid' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end


  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          customer: {
            name: 'John Doe',
            email: 'john@example.com',
            document_number: '59854923037',
            birthdate: 30.years.ago.to_date,
            income: 5000.0
          }
        }
      end

      it 'creates a new customer' do
        expect {
          post :create, params: valid_params
        }.to change(Customer, :count).by(1)
      end

      it 'returns a successful response' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          customer: {
            name: '',
            email: 'invalid_email',
            document_number: '123',
            birthdate: Date.tomorrow,
            income: -100
          }
        }
      end

      it 'does not create a new customer' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Customer, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post :create, params: invalid_params
        errors = JSON.parse(response.body)['errors']
        expect(errors).to be_present
      end
    end
  end

  describe 'PUT #update' do
    let(:customer) { create(:customer) }

    context 'with valid params' do
      let(:new_name) { 'Jane Doe' }
      let(:valid_params) do
        {
          id: customer.id,
          customer: { name: new_name }
        }
      end

      it 'updates the customer' do
        put :update, params: valid_params
        customer.reload
        expect(customer.name).to eq(new_name)
      end

      it 'returns a successful response' do
        put :update, params: valid_params
        expect(response).to be_successful
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          id: customer.id,
          customer: { email: 'invalid_email' }
        }
      end

      it 'does not update the customer' do
        put :update, params: invalid_params
        customer.reload
        expect(customer.email).not_to eq('invalid_email')
      end

      it 'returns unprocessable entity status' do
        put :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:customer) { create(:customer) }

    it 'soft deletes the customer' do
      expect {
        delete :destroy, params: { id: customer.id }
      }.to change { Customer.without_deleted.count }.by(-1)
    end

    it 'does not actually delete the record' do
      expect {
        delete :destroy, params: { id: customer.id }
      }.not_to change { Customer.with_deleted.count }
    end

    it 'sets deleted_at timestamp' do
      delete :destroy, params: { id: customer.id }
      customer.reload
      expect(customer.deleted_at).not_to be_nil
    end

    it 'returns no content status' do
      delete :destroy, params: { id: customer.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
