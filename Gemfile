source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"

gem "awesome_print"
gem 'rails', '~> 7.0.8'
gem "pg"
gem "puma", "~> 5.0"
gem "sprockets-rails", require: "sprockets/railtie"

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "rest-client"
gem "nokogiri", ">= 1.16.0"

group :development, :test do
  gem "dotenv-rails", "~> 2.7.6", require: "dotenv/rails-now"
  gem "standard"
  gem "pry-byebug"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
