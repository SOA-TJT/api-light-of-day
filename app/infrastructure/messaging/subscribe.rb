# frozen_string_literal: true

require 'aws-sdk-sns'

module LightofDay
  module Messaging
    # SNS messaging
    class Subscribe
      def initialize(config)
        # connect to sns
        @sns = Aws::SNS::Resource.new(region: 'us-east-2')
        @SNS_ARN = config
      end

      # create SNS topic if it doesn't exist
      def create(topic_id)
        unless @sns.topics.find { |topic| topic.arn.split(':').last == topic_id }
          topic = @sns.create_topic(name: topic_id)
          puts topic.arn
        end
      end

      def subscribe(email, topic_id)
        topic = @sns.topic("#{@SNS_ARN}:#{topic_id}")

        sub = topic.subscribe({
          protocol: 'email',
          endpoint: email
        })

        puts sub.arn
      end
    end
  end
end
