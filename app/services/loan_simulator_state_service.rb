class LoanSimulatorStateService
  def initialize(loan_simulator)
    @loan_simulator = loan_simulator
  end

  def transition_to(new_state, user: nil)
    Rails.logger.info("Enqueuing transition to #{new_state} for LoanSimulator ##{@loan_simulator.id}")

    event = state_to_event(new_state)

    if event
      LoanSimulatorStateWorker.perform_async(@loan_simulator.id, event.to_s) # Converte para string
      { success: true, message: "Transition to '#{new_state}' enqueued successfully." }
    else
      { success: false, error: "Invalid state: #{new_state}" }
    end
  end

  private

  def state_to_event(state)
    {
      "calculated" => :calculate,
      "approved" => :approve,
      "rejected" => :reject
    }[state]
  end

  def handle_side_effects(new_state, user)
    case new_state
    when "calculated"
      calculate_loan_details
    when "approved"
      send_approval_notification(user)
    when "rejected"
      send_rejection_notification(user)
    end
  end

  def calculate_loan_details
    LoanCalculationService.call(@loan_simulator)
  end

  def send_approval_notification(user)
    NotificationService.call(user: user, message: "Loan Simulator ##{@loan_simulator.id} has been approved.")
  end

  def send_rejection_notification(user)
    NotificationService.call(user: user, message: "Loan Simulator ##{@loan_simulator.id} has been rejected.")
  end

  def success_message(new_state)
    { success: true, message: "Loan Simulator transitioned to '#{new_state}' successfully." }
  end

  def failure_message(new_state)
    { success: false, error: "Transition to '#{new_state}' is not allowed from the current state." }
  end
end
