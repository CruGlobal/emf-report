source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"

gem "awesome_print"
gem 'rails', '~> 7.0.8'
gem "pg"
gem "puma", "~> 5.0"
gem "sprockets-rails", require: "sprockets/railtie"

gem "webpacker", "~> 5.0"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

gem "rest-client"
gem "pry-byebug"
gem "nokogiri", ">= 1.16.0"

group :development, :test do
  gem "dotenv-rails", "~> 2.7.6", require: "dotenv/rails-now"
  gem "standard"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
  gem "spring"
end
