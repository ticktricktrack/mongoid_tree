source :rubygems

# My personal global Gemfile in my work directory
if File.exist?(file = File.expand_path('../../Gemfile',__FILE__))
  instance_eval(File.read(file))
end

group :development do
  gem "jeweler"
end

gem "mongoid", ">= 2.0.0.beta.16"
# Currently used MongoDB version : 1.4.3

group :test do
  gem "rspec", ">= 2.0.0"
  gem "cucumber", ">= 0.8.5"
  gem "factory_girl"
end