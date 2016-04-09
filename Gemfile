source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.15'

# use puma as the app server
gem 'puma'

# wrapper for R interpreter
gem 'rinruby'

# sessions stored in mongodb
gem 'bson'
gem 'bson_ext'
gem 'mongo', '~> 1.12'
# Disableing due to bugs
#gem 'mongo_session_store-rails4',
#    git: 'git://github.com/kliput/mongo_session_store.git',
#    branch: 'issue-31-mongo_store-deserialization'


# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-tmpl-rails'
gem 'jit-rails'
gem 'haml'
gem 'foundation-rails'
gem 'foundation-icons-sass-rails'
gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'
gem 'font-awesome-sass', '4.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

#for mathematical functions
gem 'descriptive_statistics'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug'

  # no one uses this :) uncomment if needed
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'

  # not used
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
# end

group :test do
  gem 'mocha'
  gem 'ci_reporter_minitest'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# for local development - set path to scalarm-database
# gem 'scalarm-database', path: '/home/jliput/Scalarm/scalarm-database'
gem 'scalarm-database', '~> 1.4', git: 'git://github.com/Scalarm/scalarm-database.git'

# for local development - set path to scalarm-core
# gem 'scalarm-service_core', path: '/Users/jliput/Scalarm/scalarm-service_core'
gem 'scalarm-service_core', '~> 1.3', git: 'git://github.com/Scalarm/scalarm-service_core.git'
