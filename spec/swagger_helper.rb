require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API de Simulação de Empréstimos',
        version: 'v1',
        description: 'API para simular e gerenciar empréstimos',
        contact: {
          name: 'Priscila Cabral',
          email: 'priscilacabral.dev@gmail.com'
        }
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'local'
        }
      ],
      components: {
        schemas: {
          error: {
            type: :object,
            properties: {
              message: { type: :string },
              errors: {
                type: :array,
                items: { type: :string }
              }
            }
          }
        }
      },
      tags: [
        {
          name: 'Loan Simulators',
          description: 'Operações relacionadas a simulações de créditos'
        },
        {
          name: 'Customers',
          description: 'Operações relacionadas a clientes'
        }
      ]
    }
  }
end
