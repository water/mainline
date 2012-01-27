# Gitorious soon Water

## Installation

1. Add your database credentials under `config/database.yml` section `development`
2. Make sure you run ruby 1.9.2 using `ruby -v`, otherwise [install it](http://railscasts.com/episodes/310-getting-started-with-rails).
3. Install all dependencies using `bundle install`
4. Create an empty database `bundle exec rake db:create:all`
5. Migrate database `bundle exec rake db:migrate`