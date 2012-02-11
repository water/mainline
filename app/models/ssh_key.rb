# encoding: utf-8

require "tempfile"
require 'drb'

class SshKey < ActiveRecord::Base
  include ActiveMessaging::MessageSender
  belongs_to :user
  
  SSH_KEY_FORMAT = /^ssh\-[a-z0-9]{3,4} [a-z0-9\+=\/]+ SshKey:(\d+)?-User:(\d+)?$/ims.freeze
  
  validates_presence_of :user_id, :key
  
  before_validation { |k| k.key.to_s.strip! }
  before_validation :lint_key!
  after_create  :publish_creation_message
  # we only allow people to create/destroy keys after_update  :create_update_task 
  after_destroy :publish_deletion_message
  
  def self.human_name
    I18n.t("activerecord.models.ssh_key")
  end

  validate :keyfile_format
  def keyfile_format
    if self.to_keyfile_format !~ SSH_KEY_FORMAT
      errors.add(:key, I18n.t("ssh_key.key_format_validation_message"))
    end

    unless valid_key_using_ssh_keygen?
      errors.add(:key, "is not recognized is a valid public key")
    end
  end
  
  def wrapped_key(cols=72)
    key.gsub(/(.{1,#{cols}})/, "\\1\n").strip
  end
  
  def to_ssh_key
    %Q{### START KEY #{self.id || "nil"} ###\n} +
    %Q{command="gitorious #{user.login}",no-port-forwarding,} +
    %Q{no-X11-forwarding,no-agent-forwarding,no-pty #{to_keyfile_format}} +
    %Q{\n### END KEY #{self.id || "nil"} ###\n}
  end
  
  # The internal format we use to represent the pubkey for the sshd daemon
  def to_keyfile_format
    %Q{#{self.algorithm} #{self.encoded_key} SshKey:#{self.id}-User:#{self.user_id}}
  end
  
  def self.add_to_authorized_keys(keydata, key_file_class=SshKeyFile)
    key_file = key_file_class.new
    key_file.add_key(keydata)
  end
  
  def self.delete_from_authorized_keys(keydata, key_file_class=SshKeyFile)
    key_file = key_file_class.new
    key_file.delete_key(keydata)
  end
  
  def publish_creation_message
    options = ({:target_class => self.class.name, 
      :command => "add_to_authorized_keys", 
      :arguments => [self.to_ssh_key], 
      :target_id => self.id,
      :identifier => "ssh_key_#{id}"})
    publish :ssh_key_generation, options.to_json
  end
  
  def publish_deletion_message
    options = ({
      :target_class => self.class.name, 
      :command => "delete_from_authorized_keys", 
      :arguments => [self.to_ssh_key],
      :identifier => "ssh_key_#{id}"})
    publish :ssh_key_generation, options.to_json
  end
  
  def components
    key.to_s.strip.split(" ", 3)
  end
  
  def algorithm
    components.first
  end
  
  def encoded_key
    components.second
  end
  
  def comment
    components.last
  end

  def fingerprint
    @fingerprint ||= begin
      raw_blob = encoded_key.to_s.unpack("m*").first
      OpenSSL::Digest::MD5.hexdigest(raw_blob).scan(/../).join(":")
    end
  end

  def valid_key_using_ssh_keygen?
    temp_key = Tempfile.new("ssh_key_#{Time.now.to_i}")
    temp_key.write(self.key)
    temp_key.close
    system("ssh-keygen -l -f #{temp_key.path}")
    temp_key.delete
    return $?.success?
  end
  
  protected
    def lint_key!
      self.key.to_s.gsub!(/(\r|\n)*/m, "")
    end
end
