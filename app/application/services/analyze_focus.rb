# frozen_string_literal: true

require 'dry/monads'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class AnalyzeFocus
      include Dry::Monads::Result::Mixin

      def call
        puts 'test'
        focus_list = LightofDay::Mapper::WeeklyFocusMapper.new.day_summary
        puts 'hhh'
        Response::DailyFocuses.new(focus_list)
                              .then do |list|
          # puts list
          Response::ApiResult.new(status: :ok, message: list)
        end
                              .then { |result| Success(result) }
        # Success(focus_list)
      rescue StandardError
        # Failure('Could not find focus')
        Response::ApiResult.new(status: :api_error, message: 'API-Error')
      end
    end
  end
end
