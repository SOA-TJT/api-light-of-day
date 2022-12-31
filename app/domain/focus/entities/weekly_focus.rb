# frozen_string_literal: true

require_relative '../lib/focus_calculator'

module LightofDay
  module Entity
    class WeeklyFocus < SimpleDelegator
      def initialize(weekly)
        @weekly_list = weekly
        # @avg_rest_time = 0
        # @avg_work_time = 0
        # @total_work_time = 0
        # @total_rest_time = 0
      end

      def weekly_work
        @weekly_list.map(&:work_time).sum
      end

      def weekly_rest
        @weekly_list.map(&:rest_time).sum
      end

      def avg_weekly_work
        weekly_work.to_f / @weekly_list.length.to_f
      end

      def avg_weekly_rest
        weekly_rest.to_f / @weekly_list.length.to_f
      end
    end
  end
end
