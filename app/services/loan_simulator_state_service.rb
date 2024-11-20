class LoanSimulatorStateService
  def initialize(loan_simulator)
    @loan_simulator = loan_simulator
  end

  def transition_to(new_state, user: nil)
    Rails.logger.info("Attempting transition to #{new_state} for LoanSimulator ##{@loan_simulator.id}")
  
    event = new_state.to_sym
  
    if @loan_simulator.aasm.may_fire_event?(event)
      @loan_simulator.send("#{event}!")
      handle_side_effects(new_state, user)
      { success: true, message: "Loan Simulator transitioned to '#{new_state}' successfully." }
    else
      Rails.logger.error("Transition to #{new_state} failed for LoanSimulator ##{@loan_simulator.id}")
      { success: false, error: "Transition to '#{new_state}' is not allowed from the current state." }
    end
  rescue AASM::InvalidTransition => e
    Rails.logger.error("Invalid transition: #{e.message}")
    { success: false, error: "Invalid transition: #{e.message}" }
  end  

  private

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
