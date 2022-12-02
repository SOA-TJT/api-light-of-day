# frozen_string_literal: true

require 'dry/monads'
# require 'dry/transaction'

module LightofDay
  module Service
    # get all topics
    class FindTopics
      include Dry::Monads::Result::Mixin
      # include Dry::Transaction

      def call
        topics_mapper = LightofDay::TopicMapper.new(App.config.UNSPLASH_SECRETS_KEY)
        Success(topics_mapper)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :api_error, message: 'API-Error'))
      end
    end
  end
end
