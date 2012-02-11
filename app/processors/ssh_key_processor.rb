# encoding: utf-8
class SshKeyProcessor < ApplicationProcessor
  subscribes_to :ssh_key_generation

  def on_message(message)
    verify_connections!
    json = ActiveSupport::JSON.decode(message)
    logger.info "#{self.class.name} consuming message. Command: #{json['command']}. Arguments: #{json['arguments']}. Target_id: #{json['target_id']}"
    logger.debug("#{self.class.name} processing message #{json}")
    unless %w(add_to_authorized_keys delete_from_authorized_keys).include?(json['command'])
      raise "Unknown command"
    end
    logger.debug("Processor sending message: #{json['command']} #{json['arguments']}")
    SshKey.send(json['command'], *json['arguments'])
    if target_id = json['target_id']
      if obj = SshKey.find_by_id(target_id.to_i)
        obj.ready = true
        obj.save!
      end
    end
  end
end
