Factory.sequence :email do |n|
  "john#{n}@example.com"
end

Factory.sequence :login do |n|
  "user#{n}"
end