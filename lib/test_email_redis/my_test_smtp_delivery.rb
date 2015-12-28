module TestEmailRedis
  class TestMailDelivery < ::Mail::SMTP
    #attr_accessor :message
    attr_accessor :settings

    # SMTP configuration (could be possible to pass the settings from the config file)
    def initialize(values)
      self.settings = Rails.configuration.action_mailer.smtp_settings.merge!(values)
    end

    def deliver!(mail)
      # save to redis
      TestEmailRedis::Helpers.add_email_to_redis mail


      # SMTP standard
      # Redirect all mail to your inbox
      #mail['to'] = "youremail@domain.com"
      #mail['bcc'] = []
      #mail['cc'] = []
      super(mail)
    end
  end

end
