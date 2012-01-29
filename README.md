# Water

## Setup

### Preparation

1. Make sure you run ruby 1.9.2 using `ruby -v`, otherwise [install it](http://railscasts.com/episodes/310-getting-started-with-rails).
2. Install [beanstalkd](http://kr.github.com/beanstalkd/), used for internal messaging.
3. Install and start `mysql`, pg will be used later in the development process.
4. Install [foreman](http://railscasts.com/episodes/281-foreman) using `gem install foreman`

### Installation

1. Clone project using `git clone git@github.com:water/mainline.git water`
2. Checkout the master branch. `git checkout master`
3. Navigate to the `config` folder, create a file called `database.yml` with the your mysql credentials. [Example credentials](https://gist.github.com/a5cf8cb41bc6643e0d84)
4. Install all dependencies using `bundle install`
5. Create db, migrate db and create a user `bundle exec rake db:create db:migrate db:seed`. User credentials are printed in green.
6. Start rails server `rails s --debugger`
7. Start [poller](https://github.com/water/mainline/blob/master/script/poller) and the `beanstalkd` daemon by running `foreman start`
8. Navigate to [localhost:3000](http://localhost:3000)
9. Login using the green stuff from before.

### Install MySQL

#### Ubuntu

1. `sudo apt-get install mysql-common mysql-server libmysqlclient-dev`

#### OS X

Make sure you use the correct version of mysql in the path below. `5.5.14` is used in the example.

1. `brew install mysql`
2. `bundle config build.mysql --with-mysql-config=/usr/local/Cellar/mysql/5.5.14/bin/mysql_config`
3. `gem install mysql2 -- --with-mysql-config=/usr/local/Cellar/mysql/5.5.14/bin/mysql_config`

### Install beanstalkd

#### Ubuntu

1. `sudo apt-get install beanstalkd`

#### OS X

1. `brew install beanstalkd`

## Strange things

- Project.top_tags
- SshKey#publish_deletion_message

## Tests

### Run all specs

`bundle exec rake test`

### Run a specific file

All tests are located in the `test` directory.  
You can run a particular test file using `bundle exec ruby test/the_file_in_question.rb`

### Status current master branch

- 829 tests, 1488 assertions, 6 failures, 114 errors, 0 skips

### Status original master branch

- 1059 tests, 2110 assertions, 0 failures, 0 errors
- 975 tests, 1994 assertions, 0 failures, 0 errors
- 7 tests, 34 assertions, 0 failures, 0 errors

## Rails 2.x depreciations

Run `rake rails:upgrade:check` to list things that isn't migrated from rails `2.x` to `3.x`.