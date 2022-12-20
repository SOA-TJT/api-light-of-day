# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    class StoreLightofDay
      include Dry::Transaction

      step :store_lightofday

      private

      DB_ERR = 'Cannot access database'

      def request_random_lightofday_worker(input)
        return Success(input) if input.exists_locally? # need to modify
        a = { 'topic_id' => input }.to_json
        puts a

        Messaging::Queue
          .new(App.config.FAVORITE_QUEUE_URL, App.config)
          .send({ 'topic_id' => input }.to_json)

        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        # print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: FIND_ERR))
      end
      
      def store_lightofday(input)
        puts input
        lightofday = Repository::For.entity(input).create(input)
        if lightofday
          Success(Response::ApiResult.new(status: :created, message: lightofday))
        else
          Failure(Response::ApiResult.new(status: :bad_request, message: nil))
        end
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
