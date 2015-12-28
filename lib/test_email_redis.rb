require 'test_email_redis/helpers'

module TestEmailRedis
  #extend ActiveSupport::Autoload

  #
  @@config = {}

  def self.set_config(_config)
    @@config = _config
  end

  def self.config
    @@config ||= {}
    @@config
  end

end
