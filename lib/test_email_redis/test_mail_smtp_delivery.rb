require_relative 'helpers'

module TestEmailRedis
  class TestMailSmtpDelivery < ::Mail::SMTP
    #attr_accessor :message
    attr_accessor :settings

    # SMTP configuration (could be possible to pass the settings from the config file)
    def initialize(values)
      self.settings = Rails.configuration.action_mailer.smtp_settings.merge!(values)
    end


    def self.get_user_id_from_mail(mail)
      # save to redis
      field_to_email = TestEmailRedis.field_to_email

      if field_to_email
        user_id =mail.send(field_to_email.to_sym)
      else
        user_id = mail.to

        if user_id.is_a? Array
          user_id = user_id[0]
        end
      end

      user_id
    end



    def deliver!(mail)
      # save to redis
      user_id = TestMailDelivery.get_user_id_from_mail mail

      TestEmailRedis::Helpers.add_email_to_redis mail, user_id


      # SMTP standard
      #mail['to'] = "youremail@domain.com"
      #mail['bcc'] = []
      #mail['cc'] = []
      super(mail)
    end
  end

end
