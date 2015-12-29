#require 'test_email_redis/helpers'
#require 'test_email_redis/test_mail_delivery'

module TestEmailRedis
  if defined? ActiveSupport
    extend ActiveSupport::Autoload
  end


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
