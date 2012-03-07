# encoding: utf-8
class ApplicationProcessor < ActiveMessaging::Processor
  
  def ActiveMessaging.logger
    @@logger ||= begin
      io = Rails.env == "production" ? File.join(Rails.root, "log", "message_processing.log") : STDOUT
      logger = ActiveSupport::BufferedLogger.new(io)
      #logger.level = ActiveSupport::BufferedLogger.const_get(Rails.configuration.log_level.to_s.upcase)
      logger.level = ActiveSupport::BufferedLogger::INFO
      if Rails.env == "production"
        logger.auto_flushing = true
      end
      logger
    end
  end
  
  # Default on_error implementation - logs standard errors but keeps
  # processing. Other exceptions are raised.  Have on_error throw
  # ActiveMessaging::AbortMessageException when you want a message to
  # be aborted/rolled back, meaning that it can and should be retried
  # (idempotency matters here).  Retry logic varies by broker - see
  # individual adapter code and docs for how it will be treated
  def on_error(err, message_body)
    notify_on_error(err, message_body)
    if (err.kind_of?(StandardError))
      logger.error "#{self.class.name}::on_error for msg: #{message_body}: \n" + 
      " #{err.class.name}: " + err.message + "\n" + \
      "\t" + err.backtrace.join("\n\t")
      raise ActiveMessaging::AbortMessageException
    else
      logger.error "#{self.class.name}::on_error: #{err.class.name} raised: " + err.message
      raise err
    end
  end

  #
  # Trigger callback defined by @options["callback"]
  #   Example:
  #     @options["callback"] = {
  #       class: "Student",
  #       method: "winner"
  #    }
  #
  def handle_callback!
    if defined?(@options) and c = @options["callback"]
      logger.info("Callback passed, investigating.")
      if cons = c["class"].safe_constantize
        if cons.respond_to?(c["method"])
          logger.info("Class '#{c["class"]}##{c["method"]}' found, trigger callback.")
          options = @options.dup 
          options.delete("callback")
          return cons.send(c["method"], options)
        end
      end
    end
    klass = c.try(:[], "class") || "-"
    method = c.try(:[], "method") || "-"
    logger.info("Nothing found related to '#{klass}##{method}', nothing triggered")
  end
  
  # verify active database connections, reconnect if needed
  def verify_connections!
    ActiveRecord::Base.verify_active_connections!
  end

  protected
    def notify_on_error(err, message_body)
      Mailer.deliver_message_processor_error(self, err, message_body)
    end

end
