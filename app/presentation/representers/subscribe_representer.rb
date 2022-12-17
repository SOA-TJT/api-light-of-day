require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Subcription Representer
    class Subscribe < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :email
      property :topic_id
    end
  end
end
