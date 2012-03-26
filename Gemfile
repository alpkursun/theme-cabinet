source 'http://rubygems.org'

def gem_available?(name)
   Gem::Specification.find_by_name(name)
rescue Gem::LoadError
   false
rescue
   Gem.available?(name)
end

gem 'rails', '3.1.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5.rc.2'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

if gem_available?('mysql2')
  gem 'mysql2', :require => false
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'uuid'
end

gem "mongoid", "~> 2.4"
gem "bson_ext", "~> 1.5"
gem 'log4r'
gem 'git'
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem 'uuidtools'
gem 'fssm'
gem 'devise'
#gem 'passenger'

