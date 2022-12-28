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
      PROCESSING_MSG = 'Storing the Light of Day'
      DB_ERR = 'Cannot access database'

      def request_lightofday_worker(input)
        puts "input:", input
        input[:result] = Repository::Store.new.exists_locally(input[:requested]['origin_id'])
        puts "result:", input[:result]
        return Success(input) unless input[:result].nil? # need to modify
        puts "result is nil!"

        # Messaging::Queue
        #   .new(App.config.FAVORITE_QUEUE_URL, App.config)
        #   .send({ 'input' => input }.to_json)
        puts "json:", store_request_json(input)
        Messaging::Queue.new(App.config.FAVORITE_QUEUE_URL, App.config)
          .send(store_request_json(input))
        # test = Representer::ViewLightofDay.new(input).to_json
          Failure(Response::ApiResult.new(
            status: :processing,
            message: { request_id: input[:request_id], msg: PROCESSING_MSG }
          ))
        puts 'test'

        # Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        # print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: FIND_ERR))
      end
      
      def store_lightofday(input)
        puts input
        # lightofday = Repository::For.entity(input).find(input)
        lightofday = Repository::Store.new.exists_locally(input['origin_id'])
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

      def store_request_json(input)
        Response::StoreRequest.new(input[:requested], input[:request_id])
          .then { 
            
            Representer::StoreRequest.new(_1) 
            # puts "Store Request", _1
          }
          .then(&:to_json)
      end
    end
  end
end
