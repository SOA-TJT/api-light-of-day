# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'inspiration_representer'

# Represents essential Repo information for API output
module LightofDay
  module Representer
    # Represent a Project entity as Json
    class ViewLightofDay < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :idx
      property :lightofday
      property :inspiration, extend: Representer::Inspiration, class: OpenStruct
      property :creator_name
      property :topics
      property :urls
      property :urls_small
      property :context
      property :view_id

      link :self do
        "#{App.config.API_HOST}/api/v1/light-of-day/view/#{origin_id}"
      end

      private

      def origin_id
        represented.origin_id
      end
    end
  end
end
