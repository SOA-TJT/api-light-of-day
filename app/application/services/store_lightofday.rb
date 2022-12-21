# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    class StoreLightofDay
      include Dry::Transaction

      step :request_lightofday_worker
      step :store_lightofday

      private

      FIND_ERR = 'Could not find this lightofday'
      PROCESSING_MSG = 'Processing the summary request'
      DB_ERR = 'Cannot access database'

      def request_lightofday_worker(input)
        # a = input.value!
        # puts "input:", a
        result = Repository::For.entity(input).find(input)
        puts 'find result:', result
        return Success(input) unless result.nil? # need to modify
        a = { 'topic_id' => input }.to_json
        puts a

        Messaging::Queue
          .new(App.config.FAVORITE_QUEUE_URL, App.config)
          .send({ 'input' => input }.to_json)
          # .send(Representer::ViewLightofDay.new(input).to_json)
        puts 'test'

        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        # print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: FIND_ERR))
      end
      
      def store_lightofday(input)
        puts input
        lightofday = Repository::For.entity(input).find(input)
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
