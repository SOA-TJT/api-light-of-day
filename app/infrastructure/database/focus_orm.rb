# frozen_string_literal: true

require 'sequel'

module LightofDay
  module Database
    # Object Relational Mapper for Inspirations Entity
    class FocusOrm < Sequel::Model(:focus)
      one_to_one :focus,
                 class: :'LightofDay::Database::FocusOrm',
                 key: :uuid

      plugin :timestamps, update_on_create: true
    end
  end
end
