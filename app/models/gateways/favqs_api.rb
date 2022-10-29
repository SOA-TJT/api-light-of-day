# frozen_string_literal: true

require_relative './general_api'

module LightofDay
  module FavQs
    # FavQs api to get Data
    class Api < GeneralApi
      def quote_data
        get.parse
      end
    end
  end
end
