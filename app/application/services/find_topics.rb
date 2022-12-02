# frozen_string_literal: true

# require 'dry/monads'
require 'dry/transaction'

module LightofDay
  module Service
    # get all topics
    class ListTopics
      # include Dry::Monads::Result::Mixin
      include Dry::Transaction

      step :validate_topic
      step :retrieve_topics

      def initialize
        @topics_mapper = LightofDay::TopicMapper.new(App.config.UNSPLASH_SECRETS_KEY)
      end

      private

      def validate_topic(input)
        list_request = input[:list_request].call
        put list_request
        if input.success?
          Success(input)
        else
          Failure(input.failure)
        end
      end

      def retrieve_topics(type)
        print type
        data = if type == 'normal'
                 @topics_mapper.topics
               elsif type == 'created_time'
                 @topics_mapper.created_time
               elsif type == 'activeness'
                 @topics_mapper.activeness
               else
                 @topics_mapper.popularity
               end
        Response::Topics.new(data)
                        .then { |list| Response::ApiResult.new(status: :ok, message: list) }
                        .then { |result| Success(result) }
        # Success(data)
      rescue StandardError
        Response::ApiResult.new(status: :api_error, message: 'API-Error')
      end

      # def call(type)
      #   data = if type == 'normal'
      #            @topics_mapper.topics
      #          elsif type == 'created_time'
      #            @topics_mapper.created_time
      #          elsif type == 'activeness'
      #            @topics_mapper.activeness
      #          else
      #            @topics_mapper.popularity
      #          end
      #   Success(data)
      # rescue StandardError
      #   Failure('Having trouble accessing the topics data')
      # end

      # def find_topic(slug)
      #   chosed_topic_data = @topics_mapper.topics.find { |topic| topic.slug == slug }
      #   Success(chosed_topic_data)
      # rescue StandardError
      #   Failure('Having trouble accessing the topics data')
      # end

      # def find_slug(topic_id)
      #   chosed_topic_data = @topics_mapper.topics.find { |topic| topic.topic_id == topic_id }
      #   current_slug = chosed_topic_data.slug
      #   Success(current_slug)
      # rescue StandardError
      #   Failure('Having trouble accessing the slug')
      # end
    end
  end
end
