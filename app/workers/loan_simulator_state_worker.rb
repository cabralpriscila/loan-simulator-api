class LoanSimulatorStateWorker
  include Sidekiq::Worker

  def perform(loan_simulator_id, action)
    loan_simulator = LoanSimulator.find_by(id: loan_simulator_id)

    unless loan_simulator
      Rails.logger.error "LoanSimulator ##{loan_simulator_id} not found."
      return
    end

    case action
    when "calculate"
      calculate_loan(loan_simulator)
    when "approve"
      loan_simulator.approve!
    when "reject"
      loan_simulator.reject!
    else
      Rails.logger.warn "Unknown action '#{action}' for LoanSimulator ##{loan_simulator_id}."
    end
  rescue => e
    Rails.logger.error "Error in LoanSimulatorStateWorker for LoanSimulator ##{loan_simulator_id}: #{e.message}"
  end

  private

  def calculate_loan(loan_simulator)
    result = LoanCalculationService.call(loan_simulator)
    if result.success?
      loan_simulator.calculate! if loan_simulator.pending?
    else
      Rails.logger.error "Failed to calculate loan for LoanSimulator ##{loan_simulator.id}: #{result.error}"
    end
  end
end
