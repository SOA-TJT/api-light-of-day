# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'view_lightofday_representer'

# Represents essential Repo information for API output
module LightofDay
  module Representer
    # Representer object for project clone requests
    class StoreRequest < Roar::Decorator
      include Roar::JSON

      # property :lightofday, extend: Representer::ViewLightofDay, class: OpenStruct
      property :lightofday
      property :id
    end
  end
end
