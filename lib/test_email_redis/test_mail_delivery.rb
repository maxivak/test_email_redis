require_relative 'helpers'

module TestEmailRedis
  class TestMailDelivery
    #attr_accessor :message
    attr_accessor :settings

    # SMTP configuration (could be possible to pass the settings from the config file)
    def initialize(values)

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
      user_id = TestMailDelivery.get_user_id_from_mail mail

      #
      TestEmailRedis::Helpers.add_email_to_redis mail, user_id

    end
  end

end
