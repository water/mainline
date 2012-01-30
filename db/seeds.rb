require "colorize"

attributes = {
  login: "thedude",  
  email: "admin@popfizzle.com",  
  password: "abc123",  
  password_confirmation: "abc123",  
  terms_of_use: "1", 
  activated_at: Time.now, 
  is_admin: true
}

user = User.new(attributes)
user.login = attributes[:login]
user.save!
puts attributes.to_yaml.green