
require 'base64'
require 'dry/monads'

module LightofDay
  module Request
    # Topic list request parser
    class EncodedTopics
      include Dry::Monads::Result::Mixin
      def initialize(params)
        @params = params
      end

      def call
        Success(
          JSON.parse(decode(@params['list']))
        )
      rescue StandardError
        Failure(

        )
      def decode(param)
        Base64.urlsafe_decode64(param)
      end

      def self.to_encode64(list)
        Base64.urlsafe_encode64(list.to_json)
      end

      def self.to_request(list)
        EncodedTopics.new('list' => to_encoded(list))
      end
    end
  end
end
