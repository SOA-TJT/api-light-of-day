# frozen_string_literal: true

require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed lightofday entities
    class SubscribeEmail
      include Dry::Transaction

      step :subscribe

      AWS_ERR = 'Cannot access aws'

      def subscribe(input)
        Messaging::Email
          .new
          .subscribe(input.email)
        Success(Response::ApiResult.new(status: :ok, message: input))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: AWS_ERR)
        )
      end
    end
  end
end
