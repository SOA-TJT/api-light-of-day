# frozen_string_literal: true

require_relative '../entities/weekly_focus'
require_relative '../entities/daily_focus'

module LightofDay
  module Mapper
    # Weekly
    class WeeklyFocusMapper
      def initialize
        @focuslist = Repository::Focuses.find_last7
      end

      def for_week
        (0..6).to_a.map do |index|
          @focuslist.select do |focus|
            focus.date == Date.today - index
          end
        end
      end

      def build_entity
        Entity::WeeklyFocus.new(
          for_week
        )
      end

      def day_summary
        for_week.map.with_index do |day, index|
          Entity::DailyFocus.new(day, index)
        end
      end
    end
  end
end
