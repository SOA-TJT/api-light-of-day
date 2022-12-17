# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module LightofDay
  module Request
    # Project list request parser
    class SubscribeData
      attr_reader :email, :topic_id

      def initialize(params)
        @email = params['email']
        @topic_id = params['topic_id']
      end
    end
  end
end
