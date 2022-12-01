require 'roar/decorator'
require 'roar/json'

require_relative 'topic_representer'
require_relative 'openstruct_with_links'

module LightofDay
  module Representer
    class Topics < Roar::Decorator
      include Roar::JSON

      collection :topics, extend: Representer::Topic,
                          class: Representer::OpenStructWithLinks
    end
  end
end
