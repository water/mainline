beanstalkd: beanstalkd -p 11300
spork: bundle exec spork
poller: bundle exec ruby script/poller
grack: rackup --port 9230 -I . grack.ru
grack_test: rackup --env test --port 9231 -I . grack.ru
faye: bundle exec rackup faye.ru -s thin -E production -p 9291
