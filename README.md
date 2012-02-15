# Water

Core web application written in Rails 3

## Setup

### Preparation

1. Make sure you run ruby 1.9.2 or above using `ruby -v`, otherwise [install it](http://railscasts.com/episodes/310-getting-started-with-rails).
2. Install [beanstalkd](http://kr.github.com/beanstalkd/), used for internal messaging.
3. Install and start `mysql`, pg will be used later in the development process. See below for instructions.
4. Install [foreman](http://railscasts.com/episodes/281-foreman) using `gem install foreman`
5. Make sure you have some kind of ```sshd``` installed

### Installation

1. Clone project using `git clone git@github.com:water/mainline.git water`
2. Checkout the master branch. `git checkout master`
3. Navigate to the *config* folder, create a file called `database.yml` with the your mysql credentials. [Example credentials](https://gist.github.com/a5cf8cb41bc6643e0d84)
4. Install all dependencies using `bundle install`
5. Create db, migrate db and add a user `bundle exec rake db:create db:migrate db:seed`. User credentials are printed in green.
6. Create two empty log files, just in case rails complains about it, `touch log/development.log log/test.log`
7. Rename ```gitorious.sample.yml``` to ```gitorious.yml``` and change hosts and usernames to suit your system
8. Start server, `rails s`
9. Start [poller](https://github.com/water/mainline/blob/master/script/poller), beanstalkd and [spork](http://railscasts.com/episodes/285-spork) by running `foreman start`
10. Navigate to [localhost:3000](http://localhost:3000)
11. Login using the green stuff from before.

### Install MySQL

#### Ubuntu

1. `sudo apt-get install mysql-common mysql-server libmysqlclient-dev`

#### OS X

Make sure you use the correct version of mysql in the path below. `5.5.14` is used in the example.

1. `brew install mysql`
2. `bundle config build.mysql2 --with-mysql-config=/usr/local/Cellar/mysql/5.5.14/bin/mysql_config`
3. `gem install mysql2 -- --with-mysql-config=/usr/local/Cellar/mysql/5.5.14/bin/mysql_config`

### Install beanstalkd

#### Ubuntu

1. `sudo apt-get install beanstalkd`

#### OS X

1. `brew install beanstalkd`

## Strange things

- Project.top_tags
- SshKey#publish_deletion_message
- ActionController::TestCase.should_redirect_to_ssl

## Tests

1. Migrate test database `RAILS_ENV=test bundle exec rake db:create db:migrate`
2. Start the DRb server ([spork](http://railscasts.com/episodes/285-spork)) by running `foreman start`.
3. Wait until it says *Spork is ready and listening on 8988!*, which takes about ~20 sec.
4. Run a test
  - a specific test file `rspec spec/my_spec.rb`
  - all specs `rspec spec/`
  - a specific line in a specific file `rspec spec/my_spec.rb -l 10`

### Status current master branch

pass: 485,  fail: 25,  error: 62
total: 572 tests with 1230 assertions in 95.842623 seconds

pass: 2,  fail: 2,  error: 1
total: 5 tests with 14 assertions in 3.637961 seconds

pass: 805,  fail: 2,  error: 20
total: 827 tests with 1750 assertions in 50.656294 seconds

### Status original master branch

- 1059 tests, 2110 assertions, 0 failures, 0 errors
- 975 tests, 1994 assertions, 0 failures, 0 errors
- 7 tests, 34 assertions, 0 failures, 0 errors

## What's tested?

- models
  - archived_event
  - cloner
  - comment
  - committership
  - email
  - event
  - favourite
  - feed_item
  - git_backend
  - group
  - hook
  - mailer
  - membership
  - merge_request_status
  - user
  - merge_request_version
  - message
  - message_thread
  - page
  - project
  - repository
  - role
  - site
  - ssh_key_file
  - ssh_key
  - status_tag
  - user
  
- controllers
  - admin/users
  - messages
  - projects
  - aliases
  - blobs
  - comments
  - commits
  - committerships
  - events
  - favorites
  - groups
  - keys
  - licenses
  - memberships
  - messages
  - pages
  - projects
  - searches
  - sessions
  - site
  - trees
  
- performance
  - browsing
  
- processors
  - merge_request_git_backend
  - merge_request
  - merge_request_version
  - message_forwarding
  - push_event
  - repository_archiving
  - repository_creation
  - repository_creation
  - ssh_key
  - web_hook
 
- lib
  - breadcrumb
  - comment_callback
  - markup_renderer
  - pre_receive_guard
  
  
## Rails 2.x depreciations

Run `rake rails:upgrade:check` to list things that isn't migrated from rails `2.x` to `3.x`.

## Tips and tricks

### Ruby 1.9 syntax

Use the new hash syntax whenever possible.  

Old syntax

``` ruby
hash = {
  :a => 1,
  :b => 2
}
```

New syntax

``` ruby
hash = {
  a: 1,
  b: 2
}
```

## Should be removed

- maybe
  - archived_event
    
- models
  - merge_requests
  - merge_request_version