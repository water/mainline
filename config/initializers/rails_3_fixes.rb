class ActiveSupport::HashWithIndifferentAccess
  # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4726
  def to_json(*args, &block)
    to_hash.to_json(*args, &block)
  end
end

# Temporary fix to make {:foo => Time.new}.to_json not blow up.
class Hash
  # https://rails.lighthouseapp.com/projects/8994/tickets/4730
  def to_json(options = {})
    ActiveSupport::JSON.encode(self, options)
    # as_json(options).encode_json(ActiveSupport::JSON)
  end
end

# For some reason the rails3 paperclip branch doesn't do this.
class ActiveRecord::Base
  include Paperclip
end
