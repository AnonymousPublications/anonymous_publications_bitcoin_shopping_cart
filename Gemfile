source 'https://rubygems.org'
ruby '2.0.0'
gem 'rails', '3.2.22'

folder = File.basename(Dir.getwd)

staging_repo = folder == "upload_me"
on_heroku = folder != "upload_me" or folder != "rails3-bootstrap-devise-cancan" or folder != "anonlit"

sqlite_gem = 'sqlite3'
sqlite_gem = 'pg' if folder != "upload_me" and folder != "rails3-bootstrap-devise-cancan" and folder != "anonlit" and folder != "slow-rails3-bootstrap-devise-cancan"  # if on heroku
sqlite_gem = 'pg' if folder == "upload_me" # if on staging pre-heroku

gem 'pg'


gem sqlite_gem   # unless on_heroku or staging_repo
#gem 'pg' if staging_repo or on_heroku


gem 'i18n',         '0.6.11'

gem 'thin'
#gem 'activemerchant'
gem 'httparty'
gem 'country_select'
gem 'gpgme'
gem 'rubyzip'

group :assets do
end

gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'
gem 'haml'
gem 'jquery-rails'
gem 'bootstrap-sass', '2.3.2.1'
gem 'therubyracer'
# twitter bootstrap css & javascript toolkit
gem 'twitter-bootswatch-rails', '3.0.1.0'  #'~> 3.0.1'

# twitter bootstrap helpers gem, e.g., alerts etc...
gem 'twitter-bootswatch-rails-helpers', '3.0.0.1'

gem 'cancan'
gem 'devise'
gem 'figaro', '0.7.0'
gem 'rolify'
gem 'simple_form'
gem 'yaml_db'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'pry'
  gem 'rspec-rails', '3.1.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'quiet_assets'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'cucumber-rails', :require=>false
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  gem 'launchy'
end


# In-House gem for handling bitcoin related stuff
#gem 'bitcoin_cash_register', path: '/fast/repos/ruby/bitcoin_cash_register'
#gem 'bitcoin_cash_register-rails', path: '/fast/repos/ruby/bitcoin_cash_register-rails'
#gem 'nm_datafile', path: '/fast/repos/ruby/nm_datafile'
gem 'nm_datafile', '0.1.0'


