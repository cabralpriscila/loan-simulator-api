require 'swagger_helper'

RSpec.describe 'api/v1/loan_simulators', type: :request do
  path '/api/v1/loan_simulators' do
    get('Listar simulações de crédito') do
      tags 'Loan Simulators'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, description: 'Número da página', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Itens por página', required: false

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 loan_simulators: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       customer_id: { type: :integer },
                       requested_amount: { type: :string }, # Alterado para string
                       term_in_months: { type: :integer },
                       interest_rate: { type: :string }, # Adicionado
                       monthly_payment: { type: [ "string", "null" ] }, # Adicionado
                       total_payment: { type: [ "string", "null" ] }, # Adicionado
                       total_interest: { type: [ "string", "null" ] }, # Adicionado
                       status: { type: :string }
                     },
                     required: %w[id customer_id requested_amount term_in_months status]
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               },
               required: %w[loan_simulators pagination]

        let(:page) { 1 }
        let(:per_page) { 10 }
        let!(:loan_simulators) { create_list(:loan_simulator, 10) }

        run_test!
      end
    end
  end

  path '/api/v1/loan_simulators/{id}' do
    get('Mostrar simulações de crédito') do
      tags 'Loan Simulators'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'ID de simulação de empréstimo', required: true

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 customer_id: { type: :integer },
                 requested_amount: { type: :string }, # Alterado para string
                 term_in_months: { type: :integer },
                 interest_rate: { type: :string }, # Adicionado
                 monthly_payment: { type: [ "string", "null" ] }, # Adicionado
                 total_payment: { type: [ "string", "null" ] }, # Adicionado
                 total_interest: { type: [ "string", "null" ] }, # Adicionado
                 status: { type: :string },
                 created_at: { type: :string },
                 updated_at: { type: :string },
                 deleted_at: { type: [ "string", "null" ] }
               },
               required: %w[id customer_id requested_amount term_in_months status]

        let(:id) { create(:loan_simulator).id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
