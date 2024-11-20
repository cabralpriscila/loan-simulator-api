# Loan Simulator API
## Descrição
API para simulação de empréstimos.

### Regras de Negócio

**Elegibilidade do Cliente**

| Critério | Valor |
|----------|-------|
| Idade mínima | 18 anos |
| Idade máxima | 65 anos |
| Renda mínima | R$ 3.000,00 |

**Taxas de Juros por Faixa Etária**

| Faixa Etária | Taxa de Juros (a.a.) |
|--------------|---------------------|
| 18-25 anos   | 5,0%               |
| 26-40 anos   | 3,0%               |
| 41-60 anos   | 2,0%               |
| 60+ anos     | 4,0%               |


## Tecnologias Utilizadas
- Ruby 3.3.5
- Rails 8.0.0
- PostgreSQL
- Docker
- Swagger/OpenAPI
- Sidekiq

## Instalação
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/loan-simulator.git

# Entre no diretório
cd loan-simulator

# Inicie com Docker
docker-compose up --build
```

### Endpoints

<details>
<summary><strong>Customers</strong></summary>

#### `GET /api/v1/customers`
Lista todos os clientes.
```json
{
  "customers": [
    {
      "id": 1,
      "name": "Dobby Elfo",
      "email": "dobby@hogwarts.com",
      "document_number": "46156835024",
      "birthdate": "1990-01-01",
      "income": "5000.00"
    }
  ]
}
```

#### `POST /api/v1/customers`
Cria um novo cliente.
```json
{
  "customer": {
    "name": "Dobby Elfo",
    "email": "Dobby@hogwarts.com",
    "document_number": "46156835024",
    "birthdate": "1990-01-01",
    "income": 5000.00
  }
}

// Response (201 Created)
{
  "id": 1,
  "name": "Dobby Elfo",
  "email": "Dobby@hogwarts.com",
  "document_number": "46156835024",
  "birthdate": "1990-01-01",
  "income": "5000.00"
}
```

#### `GET /api/v1/customers/:id`
Retorna um cliente específico.

#### `PATCH /api/v1/customers/:id`
Atualiza um cliente.
```json
{
  "customer": {
    "name": "Dobby da Silva"
  }
}
```

#### `DELETE /api/v1/customers/:id`
Remove um cliente (soft delete).
</details>

<details>
<summary><strong>Loan Simulations</strong></summary>

#### `GET /api/v1/loan_simulators`
Lista todas as simulações.
```json
{
  "loan_simulators": [
    {
      "id": 1,
      "customer_id": 1,
      "requested_amount": "50000.00",
      "term_in_months": 36,
      "interest_rate": "3.00",
      "monthly_payment": "1459.78",
      "total_payment": "52552.08",
      "total_interest": "2552.08",
      "status": "calculated"
    }
  ]
}
```

#### `POST /api/v1/loan_simulators`
Cria uma nova simulação.
```json
{
  "loan_simulator": {
    "customer_id": 1,
    "requested_amount": 50000.00,
    "term_in_months": 36
  }
}

// Response (201 Created)
{
  "id": 1,
  "customer_id": 1,
  "requested_amount": "50000.00",
  "term_in_months": 36,
  "interest_rate": "3.00",
  "monthly_payment": "1459.78",
  "total_payment": "52552.08",
  "total_interest": "2552.08",
  "status": "calculated"
}
```

#### `GET /api/v1/loan_simulators/:id`
Retorna uma simulação específica.

#### `PATCH /api/v1/loan_simulators/:id/update_status`
Atualiza o status de uma simulação.
```json
{
  "status": "approved"
}
```

#### `DELETE /api/v1/loan_simulators/:id`
Remove uma simulação (soft delete).
</details>

## Desenvolvimento
### Configuração do Ambiente
```bash
# Crie e migre o banco de dados
docker-compose exec web rails db:create db:migrate db:seed

# Execute os testes
docker-compose exec web rspec

# Gere a documentação
docker-compose exec web rails rswag:specs:swaggerize
```

## Mensageria com Sidekiq
### Processamento Assíncrono
O projeto utiliza o Sidekiq para processar transições de status dos simuladores de empréstimos em segundo plano.

#### Setup do Sidekiq

```bash
# Inicializar o worker do Sidekiq
docker-compose up worker

# Acessar o painel do Sidekiq
http://localhost:3000/sidekiq
```
## Licença
Este projeto está sob a licença [MIT](LICENSE.md) 