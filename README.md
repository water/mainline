# Water

Core web application written in Rails 3

## Setup

### Preparation

1. Make sure you run ruby 1.9.2 or above using `ruby -v`, otherwise [install it](http://railscasts.com/episodes/310-getting-started-with-rails).
2. Install [beanstalkd](http://kr.github.com/beanstalkd/), used for internal messaging.
3. Install and start PostgreSQL.
4. Install [foreman](http://railscasts.com/episodes/281-foreman) using `gem install foreman`
5. Make sure you have some kind of ```sshd``` installed

### Installation

1. Clone project using `git clone git@github.com:water/mainline.git water`
2. Checkout the master branch. `git checkout master`
3. Navigate to the *config* folder, create a file called `database.yml` with the your mysql credentials. [Example credentials](https://gist.github.com/c748f0b78d35c3298efd)
4. Install all dependencies using `bundle install`
5. Create two empty log files, just in case rails complains about it, `touch log/development.log log/test.log`
6. Rename ```gitorious.sample.yml``` to ```gitorious.yml``` and change hosts and usernames to suit your system
7. Create the db and migrate it `bundle exec rake db:create db:migrate`.
8. Start [poller](https://github.com/water/mainline/blob/master/script/poller), git-daemon beanstalkd and [spork](http://railscasts.com/episodes/285-spork) by running `foreman start`
9. Seed the db `CLEAR=1 bundle exec rake db:seed`
10. Start server, `rails s`
11. Navigate to [localhost:3000](http://localhost:3000)
12. Login using the information from `db/seeds.rb`.

### Install PostgreSQL

#### Ubuntu

1. ???

#### OS X

1. `brew install postgresql`
2. `pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start`

OR

1.  Get the binary from http://www.postgresql.org/download/macosx/
The binary includes the pgAdmin program which may aid in development and debugging.

### Install beanstalkd

#### Ubuntu

1. `sudo apt-get install beanstalkd`

#### OS X

1. `brew install beanstalkd`

## Generating nice graphic of model

To better get a understanding for our model, it's nice to get a graphical
overview of it. `railroady` can create it for you automatically, install
if first by `gem install railroady` and then issue

    railroady -M | grep -v "Overwriting" | dot -Tsvg > Model.svg

where the `grep -v` part is a hack to get rid of the warnings rails
wrongly writes to stdin rather than stderr.

## Tests

1. Migrate test database `RAILS_ENV=test bundle exec rake db:create db:migrate`
2. Start the DRb server ([spork](http://railscasts.com/episodes/285-spork)) by running `foreman start`.
3. Wait until it says *Spork is ready and listening on 8988!*, which takes about ~20 sec.
4. Download fixtures using `git submodule init && git submodule update`
5. Run a test
  - a specific test file `rspec spec/my_spec.rb`
  - all specs `rspec spec/`
  - a specific line in a specific file `rspec spec/my_spec.rb -l 10`

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