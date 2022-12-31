require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Topic Representer
    class Focuses < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      collection :focuses, extend: Representer::Focus,
                          class: Representer::OpenStructWithLinks
    end
  end
end
