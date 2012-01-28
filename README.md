# Gitorious soon Water

## Setup

### Preperation

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

## Current status

Does not crash when using rails 3.0.10.

## Strange things

- Project.top_tags
- SshKey#publish_deletion_message