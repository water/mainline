# Gitorious soon Water

## Installation

1. Clone project using `git clone git@github.com:water/mainline.git water`
2. Navigate to folder and add your database credentials under `config/database.yml` section `development`
3. Make sure you run ruby 1.9.2 using `ruby -v`, otherwise [install it](http://railscasts.com/episodes/310-getting-started-with-rails).
4. Install all dependencies using `bundle install`
5. Create db, migrate db and create a user `bundle exec rake db:create db:migrate db:seed`. User credentials are printed in green.
6. Start rails server `rails s --debugger`
7. Navigate to [localhost:3000](http://localhost:3000)
8. Login using the green stuff from before.

## Current status

Does not crash when using rails 3.0.10.

## Todo

1. Remove Ultrasphinx, it's not needed in Water

## Strange things

- Project.top_tags
- SshKey#publish_deletion_message