require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Topic Representer
    class DailyFocus < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      # collection :daily_list, extend: Representer::Focus, class: Representer::OpenStructWithLinks
      property :daily_list
      property :daily_date

      # property :avg_rest_time
      # property :avg_work_time
      # property :total_work_time
      # property :total_rest_time

      property :daily_work
      property :daily_rest
      # property :avg_daily_work
      # property :avg_daily_rest
    end
  end
end
