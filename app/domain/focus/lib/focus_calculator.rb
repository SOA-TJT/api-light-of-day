# frozen_string_literal: true

module LightofDay
  module Mixins
    module FocusCalculator
      def total_rest_time
        focustimes.map(&:rest_time).sum
      end

      def total_work_time
        focustimes.map(&:work_time).sum
      end

      def avg_rest_time(length)
        return 0 if length == 0

        total_rest_time.to_f / length.to_f
      end

      def avg_work_time(length)
        return 0 if length == 0

        total_work_time.to_f / length.to_f
      end
    end
  end
end
