module TestEmailRedis
  class Helpers
    def self.config
      TestEmailRedis.config
    end

    def self.add_email_to_redis(mail, to_email=nil)
      to_email ||= mail.to[0]

      #
      data = {from: mail.from, to: mail.to, parts: []}
      mail.parts.each do |m|
        data[:parts] << {body: m.body.to_s}
      end

      #$redis.rpush key, data.to_json

      # generate uid
      uid = "#{(Time.now.utc.to_f * 1000.0).to_i.to_s}_#{Gexcore::Common.random_string_digits(2)}"
      $redis.hset redis_key_emails_content, uid, data.to_json


      # by to_email
      $redis.rpush redis_key_emails_for_email(to_email), uid

    end


    def self.clean_emails_for_email(to_email)
      $redis.del redis_key_emails_for_email(to_email)
    end

    def self.clean_emails_all
      $redis.ltrim redis_key_emails_content, 0, -1

      keys = $redis.keys redis_key_emails_for_email_base+'*'
      $redis.del keys


    end


    ### get emails
    def self.get_last_email
      v = $redis.rpop redis_key_emails_content
      return v if v.nil?

      data = JSON.parse(v)
      data
    end

    def self.get_last_email_to_email(to_email, wait=true, timeout_secs = 30, opts={})
      if opts[:clean] && opts[:clean]==true
        clean_emails_for_email to_email
      end

      #
      key = redis_key_emails_for_email(to_email)

      v = nil
      begin
        timeout 10 do
          while 1==1 do
            v = $redis.rpop key
            break unless v.nil?

            sleep 1
          end
        end
      rescue => e

      end

      return nil if v.nil?

      # get content
      content = $redis.hget redis_key_emails_content, v

      # parse
      data = JSON.parse(content)
      data
    end




    ### settings

    def self.redis_key_emails_content
      config[:redis_prefix]+":emails:content"
    end

    def self.redis_key_emails_for_email_base
      config[:redis_prefix]+":emails:by_to_email:"
    end

    def self.redis_key_emails_for_email(to_email)
      redis_key_emails_for_email_base+to_email.to_s
    end


  end
end

