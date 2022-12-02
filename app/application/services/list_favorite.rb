# frozen_string_literal: true

require 'dry/transaction'

module LightofDay
  module Service
    # Retrieves array of all listed lightofday entities
    class ListFavorite

      include Dry::Transaction

      step :validate_list
      step :retrieve_favorites

      private

      DB_ERR = 'Cannot access database'

      # Expects list of movies in input[:list_request]
      def validate_list(input)
        list_request = input[:list_request].call
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Failure(list_request.failure)
        end
      end

      def retrieve_favorites(input)
        puts input[:list].split(",")
        Repository::For.klass(Unsplash::Entity::View).find_origin_ids(input[:list].split(","))
                       .then { |favorite| Response::FavoriteList.new(favorite) }
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
