class CommitRequestProcessor < ApplicationProcessor
  subscribes_to :commit

  def on_message(message)
    puts "====> #{message}"
  end
end
