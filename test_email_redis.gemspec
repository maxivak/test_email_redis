$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "test_email_redis/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "test_email_redis"
  s.version     = TestEmailRedis::VERSION
  s.authors     = ["Max Ivak"]
  s.email       = ["max.ivak@galacticexchange.io"]
  s.homepage    = "http://maxivak.com"
  s.summary     = "Test emails using Redis"
  s.description = "Testing emails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
