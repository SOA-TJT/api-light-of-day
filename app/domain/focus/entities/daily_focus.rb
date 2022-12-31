# frozen_string_literal: true

require_relative '../lib/focus_calculator'

module LightofDay
  module Entity
    class DailyFocus < SimpleDelegator
      attr_reader :daily_date, :daily_list, :avg_rest_time, :avg_work_time, :total_work_time, :total_rest_time

      def initialize(daily, index)
        @daily_list = daily
        @daily_date = Date.today - index
        # @avg_rest_time = daily.nil? ? 0.0 : daily.map(&:rest_time).sum.to_f / daily.length.to_f
        # @avg_work_time = daily.nil? ? 0.0 : daily.map(&:work_time).sum.to_f / daily.length.to_f
        # @total_work_time = daily.nil? ? 0 : daily.map(&:work_time).sum
        # @total_rest_time = daily.nil? ? 0 : daily.map(&:rest_time).sum
      end

      def daily_work
        return 0 if daily_list.nil?

        daily_list.map(&:work_time).sum
      end

      def daily_rest
        return 0 if daily_list.nil?

        daily_list.map(&:rest_time).sum
      end

      def avg_daily_work
        return 0 if daily_list.nil?

        daily_work.to_f / daily_list.length.to_f
      end

      def avg_daily_rest
        return 0 if @daily_list.nil?

        daily_rest.to_f / @daily_list.length.to_f
      end
    end
  end
end
