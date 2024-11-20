class LoanSimulatorStateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform(loan_simulator_id, event)
    loan_simulator = LoanSimulator.find(loan_simulator_id)

    Rails.logger.info "Current state: #{loan_simulator.aasm.current_state}, Event: #{event}"

    if loan_simulator.aasm.current_state.to_s == event
      Rails.logger.info "LoanSimulator ##{loan_simulator.id} is already in state '#{event}'"
      return
    end

    if loan_simulator.aasm.may_fire_event?(event.to_sym)
      loan_simulator.send("#{event}!")
      Rails.logger.info "LoanSimulator ##{loan_simulator.id} transitioned to #{loan_simulator.status}"
    else
      Rails.logger.error "Failed to transition LoanSimulator ##{loan_simulator.id} with event #{event}"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "LoanSimulator ##{loan_simulator_id} not found"
  end
end
