# Water

## Setup

### Preparation

1. Make sure you run ruby 1.9.2 using `ruby -v`, otherwise [install it](http://railscasts.com/episodes/310-getting-started-with-rails).
2. Install [beanstalkd](http://kr.github.com/beanstalkd/), used for internal messaging.
3. Install and start `mysql`, pg will be used later in the development process.
4. Install [foreman](http://railscasts.com/episodes/281-foreman) using `gem install foreman`
5. Start the [poller](https://github.com/water/mainline/blob/master/script/poller) and `beanstalkd` daemon by running `foreman start`

### Installation

1. Clone project using `git clone git@github.com:water/mainline.git water`
2. Navigate to folder and add your database credentials under `config/database.yml` section `development`
3. Install all dependencies using `bundle install`
4. Create db, migrate db and create a user `bundle exec rake db:create db:migrate db:seed`. User credentials are printed in green.
5. Start rails server `rails s --debugger`
6. Navigate to [localhost:3000](http://localhost:3000)
7. Login using the green stuff from before.

## Strange things

- Project.top_tags
- SshKey#publish_deletion_message

## Tests

### Run

`bundle exec rake test`

### Status current master branch

- 829 tests, 1488 assertions, 6 failures, 114 errors, 0 skips

### Status original master branch

- 1059 tests, 2110 assertions, 0 failures, 0 errors
- 975 tests, 1994 assertions, 0 failures, 0 errors
- 7 tests, 34 assertions, 0 failures, 0 errors

## Rails 2.x depreciations

Run `rake rails:upgrade:check` to list things that isn't migrated from rails `2.x` to `3.x`.