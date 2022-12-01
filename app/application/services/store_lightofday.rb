# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class StoreLightofDay
      # include Dry::Monads::Result::Mixin

      # def call(input)
      #   lightofday =
      #     Repository::For.entity(input).create(input)

      #   Success(lightofday)
      # rescue StandardError => error
      #   App.logger.error error.backtrace.join("\n")
      #   Failure('Having trouble accessing the database')
      # end

      include Dry::Transaction
      # step :validate_list
      step :store_lightofday

      private

      DB_ERR = 'Cannot access database'
      # Expects list of movies in input[:list_request]
      # def validate_list(input)
      #   list_request = input[:list_request].call
      #   if list_request.success?
      #     Success(input.merge(list: list_request.value!))
      #   else
      #     Failure(list_request.failure)
      #   end
      # end

      def store_lightofday(input)
        lightofday = Repository::For.entity(input).create(input)
        # .then { |lightofday| Response::FavoriteList.new(lightofday) }
        # .then { |list| Response::ApiResult.new(status: :ok, message: list) }
        # .then { |result| Success(result) }
        Success(Response::ApiResult.new(status: :created, message: lightofday))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
