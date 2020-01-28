# Welcome to Liam Gem!

Liam is an integration between your rails app & SNS, SQS AWS Services. It allows sending a message to the AWS queue (SQS) and processes the topic name on other rails app. (microservices)

we name the gem Liam in honor to (Liam Neeson) for so many reasons!

![Image](http://beta.ems.ladbiblegroup.com/s3/content/3b78f4f35c505d72d306a86eed07d052.png)

Liam sends an important message to Marko from Tropoja

> *I dont know who you are, i don’t know what you want, but i will find youm and i will kill you*

We have a medium post [Here](https://medium.com/archdaily-on-technology/microservices-events-aws-our-path-to-improve-communication-between-our-ruby-on-rails-apps-501b65e35fa3) where we improve communication between our Rails apps and avoided create new endpoints in our apps.
BUT What's happening when the App A needs data of App B and App B is down for a microsecond?

**Welcome, Liam!**

With Liam, We can send a message easily  to SQS Service through SNS Service

The first thing:

 - *What's SNS Service?*
  Amazon Simple Notification Service (SNS) [Documentation](https://docs.aws.amazon.com/sns/latest/dg/welcome.html)

 - *What's SQS Service?*
  Amazon Simple Queue Service (SQS) [Documentation](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)

![Image](https://miro.medium.com/max/4000/1*DjlJlFUnT1UgviJzNJZ-xQ.png)

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'liam', git: 'https://github.com/alexismansilla/liam.git'

  $ bundle install
```

If you want the liam file in yout rails app then execute:

```ruby
  $ bundle exec rails install:liam
```

We're going to create 2 Liam file

 1. /config/liam.yaml
 2. /lib/task/liam.rake

## Usage

```ruby
  message    = { id: self.id, title: self.title, created_at: self.created_at }.to_json
  topic_name = 'liam_CreateArticle'

  Liam::Producer.message(topic: topic_name, message: message)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexismansilla/liam.
