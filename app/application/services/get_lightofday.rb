# frozen_string_literal: true

require 'dry/transaction'
# require 'dry/monads'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class GetLightofDay
      # include Dry::Monads::Result::Mixin

      # def call(view_id)
      #   lightofday_data = Repository::For.klass(Unsplash::Entity::View)
      #                                    .find_origin_id(view_id)

      #   Success(lightofday_data)
      # rescue StandardError
      #   Failure('Having trouble accessing the database')
      # end
      include Dry::Transaction

      # step :validate_list
      step :retrieve_lightofday

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

      def retrieve_lightofday(input)
        Repository::For.klass(Unsplash::Entity::View).find_origin_id(input)
          .then { |lightofday| Response::ViewLightofDay.new(lightofday) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
