# Test emails using Redis
Simple gem for testing emails using Redis.
It is ready to test for asynchronous emails (using Sidekiq or Resque gems).

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

### Tests: RSpec3

Require helpers in your tests and configure
```
# spec_helper.rb or rspec_helper.rb

require 'test_email_redis'
require 'test_email_redis/helpers'

TestEmailRedis.set_config({
  redis_prefix: "myapp_test",
  field_user_id: :to
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



## Test Helpers

* TestEmailRedis::Helpers.get_last_email_for_user(user_id) - return the last email for user identified by user_id.
```
TestEmailRedis::get_last_email_for_user(user_id, wait=true, opts={})

```


Examples:

```
# do not wait for message
mail = TestEmailRedis::Helpers.get_last_email_for_user(user_id, false)


```

* TestEmailRedis::n_emails_for_user(user_id) - number of emails for user
* TestEmailRedis::wait_for_new_email_for_user(user_id) - just waits till a new message arrived

* TestEmailRedis::clean_emails_all - delete all emails
* TestEmailRedis::clean_emails_for_user - delete all emails for the user





## Config options

* field_user_id - field used to identify user by mail message. By default, :to which means what user_id = mail.to


## Redis

Data stored in Redis:

```
<redis_prefix>:emails:content - hash with email contents: {mail_id: content, ..}
<redis_prefix>:emails:by_user:<user_id> - list of mail message IDs for the user: [id1, id2, id3,..]
```

## Examples

### Example. Get last email

```
email = 'myuser@gmail.com'

# emails could be already for the user
n_old = TestEmailRedis::Helpers.n_emails_for_user email

# do smth which might send email
UsersMailer.welcome(email)

# wait for a new message
mail = TestEmailRedis::Helpers.get_last_email_for_user email, true, {n_old_emails: n_old}

# ***WARNING!***
# Do not use TestEmailRedis::Helpers.get_last_email_for_user(email) - it might return an old email currently available in Redis.
# It will not work is asynchronous emails are used

```

or if you don't need old emails - just delete them before sending a new email:

```
email = 'myuser@gmail.com'

# emails could be already for the user
TestEmailRedis::Helpers.clean_emails_for_user email

# do smth which might send email
UsersMailer.welcome(email)

# wait for a new message
mail = TestEmailRedis::Helpers.get_last_email_for_user email

```


### Example. Multiple emails in one test example


Multiple emails:
```
email = 'myuser@gmail.com'

# emails could be already for the user
n_old = TestEmailRedis::Helpers.n_emails_for_user email

# do smth which might send email
UsersMailer.welcome(email)
# so smth else
# send another email
UsersMailer.newsletter(email)

# for now, two emails has been sent.

# wait for a second message to arrive
mail = TestEmailRedis::Helpers.get_last_email_for_user email, true, {n_old_emails: n_old+1}


```
