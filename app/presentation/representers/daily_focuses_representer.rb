require 'roar/decorator'
require 'roar/json'

require_relative 'daily_focus_representer'
require_relative 'openstruct_with_links'

module LightofDay
  module Representer
    class DailyFocuses < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      collection :dailyfocuses, extend: Representer::DailyFocus,
                                class: Representer::OpenStructWithLinks
      # link :self do
      #   "#{App.config.API_HOST}/api/v1/topics?sort=normal"
      # end
      # link :self do
      #   "#{App.config.API_HOST}/api/v1/topics?sort=created_time"
      # end
      # link :self do
      #   "#{App.config.API_HOST}/api/v1/topics?sort=popularity"
      # end
      # link :self do
      #   "#{App.config.API_HOST}/api/v1/topics?sort=activeness"
      # end
    end
  end
end
