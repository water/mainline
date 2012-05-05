class SubmissionProcessor < ApplicationProcessor
  subscribes_to :submission
  def on_message(message)
    verify_connections!
    json = ActiveSupport::JSON.decode(message)
  end
end