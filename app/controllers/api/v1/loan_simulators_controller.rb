module Api
  module V1
    class LoanSimulatorsController < ApplicationController
      before_action :set_loan_simulator, only: [ :show, :update, :destroy, :update_status ]

      def index
        @loan_simulators = LoanSimulator.page(params[:page]).per(params[:per_page] || 10)

        render json: {
          loan_simulators: @loan_simulators.map { |simulator| decorate_simulator(simulator) },
          pagination: {
            current_page: @loan_simulators.current_page,
            next_page: @loan_simulators.next_page,
            prev_page: @loan_simulators.prev_page,
            total_pages: @loan_simulators.total_pages,
            total_count: @loan_simulators.total_count
          }, status: :ok
        }
      end

      def show
        render json: decorate_simulator(@loan_simulator), status: :ok
      end

      def create
        @loan_simulator = LoanSimulator.new(loan_simulator_params)

        if @loan_simulator.save
          LoanCalculationService.call(@loan_simulator)
          render json: decorate_simulator(@loan_simulator), status: :created
        else
          render json: { errors: @loan_simulator.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @loan_simulator.update(loan_simulator_params)
          render json: decorate_simulator(@loan_simulator)
        else
          render json: { errors: @loan_simulator.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @loan_simulator.destroy
        head :no_content
      end

      def update_status
        allowed_statuses = %w[pending calculated approved rejected]
        status = params[:status]

        unless allowed_statuses.include?(status)
          return render json: { error: "Status inválido: #{status}" }, status: :unprocessable_entity
        end

        result = LoanSimulatorStateService.new(@loan_simulator).transition_to(status)

        if result[:success]
          render json: { message: result[:message] }, status: :ok
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      private

      def set_loan_simulator
        @loan_simulator = LoanSimulator.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Simulador de crédito não encontrado" }, status: :not_found
      end

      def loan_simulator_params
        params.require(:loan_simulator).permit(:customer_id, :requested_amount, :term_in_months)
      end

      def decorate_simulator(simulator)
        {
          id: simulator.id,
          customer_id: simulator.customer_id,
          status: simulator.status,
          term_in_months: simulator.term_in_months,
          requested_amount: ActiveSupport::NumberHelper.number_to_currency(simulator.requested_amount, unit: "R$", separator: ",", delimiter: "."),
          monthly_payment: simulator.monthly_payment ? ActiveSupport::NumberHelper.number_to_currency(simulator.monthly_payment, unit: "R$", separator: ",", delimiter: ".") : nil,
          interest_rate: simulator.interest_rate ? "#{simulator.interest_rate}%" : "N/A",
          total_payment: simulator.total_payment ? ActiveSupport::NumberHelper.number_to_currency(simulator.total_payment, unit: "R$", separator: ",", delimiter: ".") : nil
        }
      end
    end
  end
end
