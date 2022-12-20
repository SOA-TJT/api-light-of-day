# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class FindLightofDay
      include Dry::Monads::Result::Mixin

      # step :request_random_lightofday_worker
      # step :remote_lightofday

      # private

      # FIND_ERR = 'Could not find this lightofday'
      # PROCESSING_MSG = 'Processing the summary request'
      DB_ERR = 'Cannot access database'

      # def request_random_lightofday_worker(input)
      #   # return Success(input) if input.exists_locally? # need to modify
      #   a = { 'topic_id' => input }.to_json
      #   puts a

      #   Messaging::Queue
      #     .new(App.config.FAVORITE_QUEUE_URL, App.config)
      #     .send({ 'topic_id' => input }.to_json)

      #   Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      # rescue StandardError
      #   # print_error(e)
      #   Failure(Response::ApiResult.new(status: :internal_error, message: FIND_ERR))
      # end

      def call(input)
        lightofday = LightofDay::Unsplash::ViewMapper
                          .new(App.config.UNSPLASH_SECRETS_KEY,
                               input).find_a_photo

        # lightofday = Response::FavoriteList.new(call_lightofday)
        Success(Response::ApiResult.new(status: :ok, message: lightofday))
      rescue StandardError
        # App.logger.error "Could not find..."
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
