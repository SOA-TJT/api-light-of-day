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
      
      def request_cloning_worker(input)
        return Success(input) if input[:gitrepo].exists_locally?

        Messaging::Queue
          .new(App.config.CLONE_QUEUE_URL, App.config)
          .send(Representer::Project.new(input[:project]).to_json)

        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: CLONE_ERR))
      end

      def remote_lightofday(input)
        lightofday = LightofDay::Unsplash::ViewMapper
                     .new(App.config.UNSPLASH_SECRETS_KEY,
                          input).find_a_photo

        Success(Response::ApiResult.new(status: :ok, message: lightofday))
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
