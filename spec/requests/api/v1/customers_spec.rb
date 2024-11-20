require 'swagger_helper'

RSpec.describe 'api/v1/customers', type: :request do
  path '/api/v1/customers' do
    get('list customers') do
      tags 'Customers'
      produces 'application/json'
      parameter name: :include_deleted, in: :query, type: :boolean, required: false,
                description: 'Include soft deleted customers'

      response(200, 'successful') do
        schema type: :object,
              properties: {
                customers: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string },
                      email: { type: :string },
                      document_number: { type: :string },
                      phone: { type: :string, nullable: true },
                      address: { type: :string, nullable: true },
                      city: { type: :string, nullable: true },
                      state: { type: :string, nullable: true },
                      zip_code: { type: :string, nullable: true },
                      birthdate: { type: :string, format: 'date' },
                      income: { type: :string, format: 'decimal' },
                      deleted_at: { type: :string, format: 'date-time', nullable: true },
                      created_at: { type: :string, format: 'date-time' },
                      updated_at: { type: :string, format: 'date-time' }
                    },
                    required: %w[id name email document_number birthdate income created_at updated_at]
                  }
                }
              }

        let!(:customers) { create_list(:customer, 3) }
        run_test!
      end
    end

    post('create customer') do
      tags 'Customers'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string },
              document_number: { type: :string },
              phone: { type: :string },
              address: { type: :string },
              city: { type: :string },
              state: { type: :string },
              zip_code: { type: :string },
              birthdate: { type: :string, format: 'date' },
              income: { type: :number }
            },
            required: %w[name email document_number birthdate income]
          }
        }
      }

      response(201, 'created') do
        let(:customer) { { customer: attributes_for(:customer) } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:customer) { { customer: attributes_for(:customer, email: 'invalid') } }
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }
        run_test!
      end
    end
  end

  path '/api/v1/customers/{id}' do
    parameter name: :id, in: :path, type: :integer
    parameter name: :include_deleted, in: :query, type: :boolean, required: false

    get('show customer') do
      tags 'Customers'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 email: { type: :string },
                 document_number: { type: :string },
                 phone: { type: :string, nullable: true },
                 address: { type: :string, nullable: true },
                 city: { type: :string, nullable: true },
                 state: { type: :string, nullable: true },
                 zip_code: { type: :string, nullable: true },
                 birthdate: { type: :string, format: 'date' },
                 income: { type: :string, format: 'decimal' },
                 deleted_at: { type: :string, format: 'date-time', nullable: true },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id name email document_number birthdate income created_at updated_at]

        let(:id) { create(:customer).id }
        run_test!
      end
    end

    patch('update customer') do
      tags 'Customers'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string },
              phone: { type: :string },
              address: { type: :string },
              city: { type: :string },
              state: { type: :string },
              zip_code: { type: :string },
              income: { type: :number }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:id) { create(:customer).id }
        let(:customer) { { customer: { name: 'New Name' } } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:id) { create(:customer).id }
        let(:customer) { { customer: { email: 'invalid' } } }
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }
        run_test!
      end
    end

    delete('delete customer') do
      tags 'Customers'
      produces 'application/json'

      response(204, 'no content') do
        let(:id) { create(:customer).id }
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end
    end
  end
end
