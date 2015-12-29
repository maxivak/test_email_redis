module TestEmailRedis
  class Helpers
    def self.config
      TestEmailRedis.config
    end


    def self.get_user_id_from_mail(mail)
      # save to redis
      field_to_email = TestEmailRedis.field_user_id

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



    def self.add_email_to_redis(mail)
      #
      user_id = get_user_id_from_mail mail


      #
      data = {from: mail.from, to: mail.to, in_reply_to: mail.in_reply_to, parts: []}
      mail.parts.each do |m|
        data[:parts] << {body: m.body.to_s}
      end

     #$redis.rpush key, data.to_json

      # generate uid
      uid = "#{(Time.now.utc.to_f * 1000.0).to_i.to_s}_#{Gexcore::Common.random_string_digits(2)}"
      $redis.hset redis_key_emails_content, uid, data.to_json


      # by to_email
      $redis.rpush redis_key_emails_for_user(user_id), uid

    end


    def self.clean_emails_for_user(user_id)
      $redis.del redis_key_emails_for_user(user_id)
    end

    def self.clean_emails_all
      $redis.del redis_key_emails_content

      keys = $redis.keys redis_key_emails_for_email_base+'*'
      keys.each do |key|
        $redis.del key
      end



    end


    ### get emails
=begin
    def self.get_last_email
      v = $redis.rpop redis_key_emails_content
      return v if v.nil?

      data = JSON.parse(v)
      data
    end
=end


    def self.wait_for_new_email_for_user(user_id, opts={})
      key = redis_key_emails_for_user(user_id)

      #
      timeout_secs = opts[:timeout] || 60
      n0 = opts[:n_old_emails] || 0

      #
      ok = false
      n = nil
      begin
        timeout timeout_secs do
          while 1==1 do
            n = $redis.llen key
            if n > n0
              ok = true
              break
            end

            sleep 1
          end
        end
      rescue => e

      end

      ok
    end

    def self.n_emails_for_user(user_id)
      $redis.llen redis_key_emails_for_user(user_id)
    end

    def self.get_last_email_for_user(user_id, wait=true, opts={})
      timeout_secs = opts[:timeout] || 60

      # wait if needed
      ok_wait = true
      if wait
        ok_wait = wait_for_new_email_for_user user_id, opts
      end

      # no email received
      return nil unless ok_wait

      #
      key = redis_key_emails_for_user(user_id)
      v = $redis.rpop key

      # push element back to the list
      $redis.rpush key, v

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
      config[:redis_prefix]+":emails:by_user:"
    end

    def self.redis_key_emails_for_user(user_id)
      redis_key_emails_for_email_base+user_id.to_s
    end


  end
end

