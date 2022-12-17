# frozen_string_literal: true

require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed lightofday entities
    class SubscribeNew
      include Dry::Transaction

      step :create_topic
      step :subscribe_topic

      AWS_ERR = 'Cannot access aws'

      # create SNS topic if it doesn't exist
      def create_topic(input)
        Messaging::Subscribe
          .new(App.config.SNS_ARN)
          .create(input.topic_id)
        Success(input)
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: AWS_ERR)
        )
      end

      def subscribe_topic(input)
        Messaging::Subscribe
          .new(App.config.SNS_ARN)
          .subscribe(input.email, input.topic_id)
        Success(Response::ApiResult.new(status: :ok, message: input))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: AWS_ERR)
        )
      end
    end
  end
end
