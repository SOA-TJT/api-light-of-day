require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Topic Representer
    class Focus < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :ssid
      property :uuid
      property :rest_time
      property :work_time
      property :date
      # property :topic_id
      # property :title
      # property :slug
      # property :starts_at
      # property :total_photos
      # property :description
      # property :topic_url
      # property :preview_photos
    end
  end
end
