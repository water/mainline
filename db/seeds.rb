require "colorize"

attributes = {
  login: "the-dude", 
  email: "admin@popfizzle.com", 
  password: "abc123", 
  password_confirmation: "abc123", 
  terms_of_use: "1",
  activated_at: Time.now,
  is_admin: true
}

User.create(attributes)

puts attributes.to_yaml.green