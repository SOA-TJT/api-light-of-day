
require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Topic Representer
    class Topic<Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :topic_id
      property :title
      property :slug
      property :starts_at
      property :total_photos
      property :description
      property :topic_url
      property :preview_photos

      link :self do
         "#{App.config.API_HOST}/api/v1/topics"
      end

    end
  end
end
