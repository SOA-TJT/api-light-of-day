# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class FindLightofDay
      include Dry::Transaction

      step :remote_lightofday

      private

      DB_ERR = 'Cannot access database'

      def remote_lightofday(input)
        lightofday = LightofDay::Unsplash::ViewMapper
                     .new(App.config.UNSPLASH_SECRETS_KEY,
                          input).find_a_photo

        Success(Response::ApiResult.new(status: :created, message: lightofday))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
