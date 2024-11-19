module Api
  module V1
    class LoanSimulatorsController < ApplicationController
      def index
        @loan_simulators = LoanSimulator.page(params[:page]).per(params[:per_page] || 10)

        render json: {
          loan_simulators: @loan_simulators,
          pagination: {
            current_page: @loan_simulators.current_page,
            next_page: @loan_simulators.next_page,
            prev_page: @loan_simulators.prev_page,
            total_pages: @loan_simulators.total_pages,
            total_count: @loan_simulators.total_count
          }
        }, status: :ok
      end
    end
  end
end
