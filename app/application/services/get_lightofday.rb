# frozen_string_literal: true

require 'dry/transaction'
# require 'dry/monads'

module LightofDay
  module Service
    # Retrieves array of all listed lightofday entities
    class GetLightofDay
      include Dry::Transaction

      step :retrieve_lightofday

      private

      DB_ERR = 'Cannot access database'

      def retrieve_lightofday(input)
        puts input
        lightofday = Repository::For.klass(Unsplash::Entity::View).find_origin_id(input)

        Success(Response::ApiResult.new(status: :created, message: lightofday))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
