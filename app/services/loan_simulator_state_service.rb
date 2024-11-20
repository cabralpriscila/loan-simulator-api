class LoanSimulatorStateService
  def initialize(loan_simulator)
    @loan_simulator = loan_simulator
  end

  def transition_to(new_state)
    event = state_to_event(new_state)

    if event && @loan_simulator.aasm.may_fire_event?(event)
      @loan_simulator.send("#{event}!")
      { success: true, message: "Transition to '#{new_state}' succeeded." }
    else
      { success: false, error: "Transition to '#{new_state}' is not allowed from the current state." }
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
