# frozen_string_literal: true

require_relative 'views'
require_relative 'inspirations'
require_relative '../../focus/repositories/focuses'

module LightofDay
  module Repository
    # Distbute mappers into correct mapper
    module For
      ENTITY_REPOSITORY = {
        LightofDay::Unsplash::Entity::View => Views,
        LightofDay::FavQs::Entity::Inspiration => Inspirations,
        LightofDay::OwnDb::Entity::Focus => LightofDay::Repository::Focuses
      }.freeze
      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
