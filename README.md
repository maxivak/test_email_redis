# Test emails using Redis
Simple gem for testing emails using Redis.

## Overview


## Usage

Gemfile:
```
gem 'test_email_redis'

```

### Application

Config gem:
```
# config/initializers/test_email_redis.rb

TestEmailRedis.set_config({
  redis_prefix: "myapp_#{Rails.env}",
  field_user_id: :to
})

```

Configure mail delivery:
```
# config/environments/test.rb

Rails.application.configure do
...

#
require 'test_email_redis/test_mail_delivery'
ActionMailer::Base.add_delivery_method :my_test_delivery, TestEmailRedis::TestMailDelivery
config.action_mailer.delivery_method = :my_test_delivery

end

```

### Tests

Require helpers in your tests and configure
```
# spec_helper.rb

require 'test_email_redis'
require 'test_email_redis/helpers'

TestEmailRedis.set_config({
  redis_prefix: "myapp_test"
})

```


Test:
```
RSpec.describe "Register user", :type => :request do

  describe 'register user' do

    before :each do
      # delete all emails if needed
      TestEmailRedis::Helpers.clean_emails_all

    end

    after :each do
      TestEmailRedis::Helpers.clean_emails_all
    end


    it 'sends email' do
       # do smth that sends email

       email = 'myuser@gmail.com'

       #...
       UsersMailer.welcome(email)

       # check email is received
       # by default, it will wait till the email is received
       mail = TestEmailRedis::Helpers.get_last_email_for_user email

       expect(mail).to be_truthy

       # analyze mail content
       html = mail['parts'][0]['body']
       text = mail['parts'][1]['body']

       expect(html).to match(/Welcome/)

    end

  end
end


```


## Mail delivery

The gem provides custom mailers:
* TestMailDelivery - add mail message to Redis
* TestMailSmtpDelivery - add mail message to Redis and send via SMTP

Use custom mail deliveries:
```
# config/environments/test.rb

Rails.application.configure do

require 'test_email_redis/test_mail_delivery'
ActionMailer::Base.add_delivery_method :my_test_delivery, TestEmailRedis::TestMailDelivery
# or
# ActionMailer::Base.add_delivery_method :my_test_delivery, TestEmailRedis::TestMailSmtpDelivery
config.action_mailer.delivery_method = :my_test_delivery

end

```

## Redis

Data stored in Redis:

```
<redis_prefix>:emails:content - hash with email contents: {mail_id: content, ..}
<redis_prefix>:emails:by_user:<user_id> - list of mail message IDs for the user: [id1, id2, id3,..]


```

## Helpers

## Config options

* field_user_id - field used to identify user by mail message. By default, :to.

## Examples

### Example. Multiple emails in one test example
