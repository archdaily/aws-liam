# AWS Liam

Liam is how we decided to call the implementation we did for our events based communication between different Ruby on Rails apps within our AWS infrastructure. We think it can be usefull for some of you that are struggling with this kind of issues too.

We called it Liam in honor to Liam Neeson for so many reasons, being the most important this iconic scene when Bryan (Liam) called Marko and said:

![Liam](https://pmctvline2.files.wordpress.com/2015/09/taken-prequel.jpg)

> *I DONT KNOW WHO YOU ARE, I DON’T KNOW WHAT YOU WANT, BUT I WILL FIND YOU AND I WILL KILL YOU*...

We wrote an [article at Medium](https://medium.com/archdaily-on-technology/microservices-events-aws-our-path-to-improve-communication-between-our-ruby-on-rails-apps-501b65e35fa3) where we explained the whole problem we had when we tried to use plain POST http requests between applications.

After implementing this solution in a couple of apps, Alexis and Sebastian decided to create this gem to encapsulate all the needed code.


# The Gem

With AWS Liam we can easily send an event (a message) from App A to App B using [SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) and [SNS](https://docs.aws.amazon.com/sns/latest/dg/welcome.html). 

The architecture you'll need is very simple: create as many SQS queues as applications you have (it's a good idea to call them `liam_NAME_OF_APPLICATION`, for example `liam_service_a` and `liam_service_b`) and as many SNS topics as events you want to work on (it's a good idea to call them `liam_NAME_OF_THE_EVENT`, for example `liam_ArticleCreated`, `liam_product_edited`, etc) and then subscribe the queues from the Services that need to consume the events from each topic as showed in the image bellow.

![Image](https://miro.medium.com/max/4000/1*DjlJlFUnT1UgviJzNJZ-xQ.png)

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'aws-liam', require: 'liam'
```
Then run a simple:
```
  $ bundle install
```

Then execute this little rake tast that will generate some configuration files needed.

```
  $ bundle exec rails g liam:install
```

2 files will be created:

 1. /config/liam.yaml
 2. /lib/task/liam.rake

Go to the first one an setup your credentials and topics endpoints at AWS. The second rake task should need to be called in Service B (and whenever you want to keep listening from new messages)

## Usage

### The Producer (Service A)
Every time something happens in Service A that needs to be shared to other applications (for example, an article was published) you need to put this simple three lines (basically create the article JSON, define where do you want to send the message and send the message):

```ruby
  message    = { id: id, title: title, created_at: created_at }
  topic_name = 'liam_ArticleCreated'

  Liam::Producer.message(topic: topic_name, message: message)
```

### The Consumer (Service B)
In the oher hand you will have to create a method in Service B that will consume the message received from Service A. At this point Class names is very important.

If you called the topic `liam_ArticleCreated` then you'll need to create a class called `ArticleCreated` within an `Liam` module at Service B, like the following example.

```ruby
# app/services/liam/article_created.rb

module Liam
  class ArticleCreated
    def initialize(message)
      @message = message
    end

    def process
      # Do all you need to do related to this article (at @message) that has been created at Service A
    end
  end
end
```
All of these files should live at `app/services/liam`.

Now you have to run the included task inside the Consumer App (make sure this task runs for ever):

```
$ bundle exec rake liam:consumer:start production
```

And that's it!

## Testing
Can you run the test easily executing

```
  $ bundle exec rspec
```

If you want to run all test successfully, we need the LocalStack daemon when sending a message

## Localstack Running
  TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/archdaily/aws-liam.
