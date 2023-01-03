require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Subcription Representer
    class Email < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

    end
  end
end
