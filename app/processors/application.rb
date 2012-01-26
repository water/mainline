# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
class ApplicationProcessor < ActiveMessaging::Processor
  
  def ActiveMessaging.logger
    @@logger ||= begin
      io = Rails.env == "development" ? STDOUT : File.join(Rails.root, "log", "message_processing.log")
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
  
  # verify active database connections, reconnect if needed
  def verify_connections!
    ActiveRecord::Base.verify_active_connections!
  end

  protected
    def notify_on_error(err, message_body)
      Mailer.deliver_message_processor_error(self, err, message_body)
    end

end
