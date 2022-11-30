# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'view_lightofday_representer'

module CodePraise
  module Representer
    # Represents list of projects for API output
    class FavoriteList < Roar::Decorator
      include Roar::JSON

      collection :view_lightofdays, extend: Representer::ViewLightofDay,
                            class: Representer::OpenStructWithLinks
    end
  end
end
