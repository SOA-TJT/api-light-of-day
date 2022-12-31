# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'
require_relative '../lib/focus_calculator'

module LightofDay
  module OwnDb
    module Entity
      # entity for quote
      class Focus < Dry::Struct
        include Mixins::FocusCalculator
        include Dry.Types
        attribute :id, Integer.optional
        attribute :ssid, Strict::String
        attribute :uuid, Strict::String
        attribute :rest_time, Strict::Integer
        attribute :work_time, Strict::Integer
        attribute :date, Strict::Date

        def to_attr_hash
          to_hash.except(:id)
        end

        def to_json(*_args)
          arr = instance_variables.map do |attribute|
            { attribute => instance_variable_get(attribute) }
          end
          arr[0].to_json
        end
      end
    end
  end
end
