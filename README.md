# Performify

It's well-known practice that has been proved in many large projects to move server logic into separated service classes. This approach gives a lot of advantages, because when you are able to create object that incapsulates your logic it's much easier to develop, search, control and test. And `performify` helps you to do it in nice and easy way with minimum of pain and maximum of result.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'performify'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install performify
```

## Usage

How to have a deal with services:

1. Define `ApplicationService`
2. Create new service inherited from `ApplicationService`
3. Implement `execute!` method
4. Use `super` to work with db transaction and automatic success / fail workflow control
5. Use `success!` and `fail!` to control everything by hands
6. Use `on_success` / `on_fail` to define callbacks

### ApplicationService

So, first of all it's better to create `ApplicationService` class that will be used as base for all services in your project. You can put any shared logic (like, authorization, for example) here:

```ruby
class ApplicationService < Performify::Base
  def authorize!(record)
    # you can put authorization logic here and use it from inherited services
  end
end
```

This is, for example, how authorization can be implemented for `Pundit`:

```ruby
class ApplicationService < Performify::Base
  def authorize!(record, query = default_query, record_policy = nil)
    record_policy ||= policy(record)
    return if record_policy.public_send(query)

    raise Pundit::NotAuthorizedError, query: query, record: record, policy: record_policy
  end

  def default_query
    @default_query ||= "#{self.class.name.demodulize.underscore.to_sym}?"
  end

  def policy(record)
    @policy ||= Pundit.policy!(@current_user, record)
  end
end
```

### Service: database

Now, to define new service just create new class and inherit it from `ApplicationService`:

```ruby
module Users
  class Destroy < ApplicationService
    def execute!
      # current user is already available, so feel free to use it
      # to get user's context

      authorize! current_user unless force?

      # block passed into super's implementation will be executed
      # in transaction, so you can do multiple data operations, and final
      # result of this block will be used to determine result of execution

      super do
        if current_user.update(destroyed_at: Time.zone.now)
          current_user.comments.find_each do |c|
            s = Comments::Destroy.new(current_user, c)
            s.execute!

            # it's also ok to raise ActiveRecord::Rollback, it will be handled
            # gracefully as regular execution fail

            raise ActiveRecord::Rollback unless s.success?
          end
        end
      end
    end

    def force?
      # additional instance variables can be passed as named args into
      # initializer and accessed by in service flow

      force.present?
    end
  end
end
```

Now you can create instance of your service and check result of execution:

```ruby
service = Users::Destroy.new(current_user, force: true)
service.execute!
service.success? # or service.fail?
```

### Service: HTTP API

Sometimes your service doesn't work with database, but calls some http endpoint or do some other stuff that doesn't require db transaction. In this case you can control your service flow manually:

```ruby
class Stripe::Create < ApplicationService
  attr_reader :subscription

  def execute!
    # here you can go to Stripe and create subscription for the user
    begin
      @subscription = Stripe::Subscription.create(
        customer: current_user.customer_id,
        plan: selected_plan.stripe_name,
      )

      # everything looks ok, success

      success!
   rescue Stripe::StripeError => e
      # something went wrong, let's notify developers and say that
      # service execution has been failed

     Airbrake.notify(e)
     fail!
   end
  end
end
```

### Callbacks

If you need to do something on service success / fail it is possible to define appropriate callbacks. Notice, that in case of using `super` callbacks will be executed outside of db transaction, so it's safe to send emails from there, for example.

```ruby
module Passwords
  class Update < ApplicationService
    def execute!
      authorize! current_user

      super do
        current_user.update(password: password, password_confirmation: password_confirmation)
      end
    end

    # you can pass method name as a callback

    on_success :invalidate_sessions

    # or you can pass block instead of method name

    on_success { UserMailer.password_changed(current_user).deliver_later }

    private def invalidate_sessions
      # you can invalidate existing user's sessions here
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. To release a new version, update the version number in `version.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/performify.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
