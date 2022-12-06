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
