require_relative 'helpers'

module TestEmailRedis
  class TestMailDelivery
    #attr_accessor :message
    attr_accessor :settings

    # SMTP configuration (could be possible to pass the settings from the config file)
    def initialize(values)

    end

    def deliver!(mail)
      TestEmailRedis::Helpers.add_email_to_redis mail

    end
  end

end
