# frozen_string_literal: true

require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed lightofday entities
    class SubscribeEmail
      include Dry::Transaction

      step :subscribe

      AWS_ERR = 'Cannot access aws'
      PROCESSING_MSG = 'Processing the random view request'

      def subscribe(input)
        Messaging::Queue
          .new(App.config.SUBSCRIBE_QUEUE_URL, App.config)
          .send({ 'action' => 'subscribe', 'email' => input.email, 'topic_id' => input.topic_id }.to_json)
        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: AWS_ERR)
        )
      end
    end
  end
end
