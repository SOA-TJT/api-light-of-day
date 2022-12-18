# frozen_string_literal: true

require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed lightofday entities
    class EmailLightOfDay
      include Dry::Transaction

      step :send_lightofday_worker

      AWS_ERR = 'Cannot access aws'
      PROCESSING_MSG = 'Processing the random view request'

      def send_lightofday_worker(input)
        # Messaging::Queue
        #   .new(App.config.CLONE_QUEUE_URL, App.config)
        #   .send({ 'email' => input.email, 'topic_id' => input.topic_id }.to_json)

        Messaging::Email.new.send(input.email, input.topic_id)
        Success(Response::ApiResult.new(status: :ok, message: input))
        # Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: AWS_ERR)
        )
      end
    end
  end
end
