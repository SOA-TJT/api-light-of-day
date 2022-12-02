# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Represents essential Member information for API output
    # USAGE:
    #   member = Database::MemberOrm.find(1)
    #   Representer::Member.new(member).to_json
    class Inspiration < Roar::Decorator
      include Roar::JSON
      property :id
      property :origin_id
      property :quote
      property :author
      property :topics
    end
  end
end
