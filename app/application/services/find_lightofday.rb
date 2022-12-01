# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class FindLightofDay
      # include Dry::Monads::Result::Mixin
      # def call(topic_data)
      #   lightofday = LightofDay::Unsplash::ViewMapper
      #                .new(App.config.UNSPLASH_SECRETS_KEY,
      #                     topic_data.topic_id).find_a_photo

      #   Success(lightofday)
      # rescue StandardError
      #   Failure('Could not find light of day')
      # end
      include Dry::Transaction
      step :remote_lightofday

      private

      DB_ERR = 'Cannot access database'
      def remote_lightofday(input)
        lightofday = LightofDay::Unsplash::ViewMapper
                     .new(App.config.UNSPLASH_SECRETS_KEY,
                          input).find_a_photo
        # .then { |lightofday| Response::FavoriteList.new(lightofday) }
        #  .then { |list| Response::ApiResult.new(status: :ok, message: list) }
        #  .then { |result| Success(result) }
        Success(Response::ApiResult.new(status: :created, message: lightofday))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
