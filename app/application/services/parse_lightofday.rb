# frozen_string_literal: true

require 'dry-transaction'
require 'dry-monads'

module LightofDay
  module Service
    # Transaction to store project from Github API to database
    class ParseLightofday
      include Dry::Transaction

      step :parse_lightofday

      private

      def parse_lightofday(input)
        puts input['inspiration']
        inspiration_record = create_inspiration(input['inspiration'])
        view_record = create_view(input, inspiration_record)
        Success(view_record)
      end

      # help methods
      def create_inspiration(data)
        # inspiration_hash = eval(data)

        LightofDay::FavQs::Entity::Inspiration.new(
          id: nil,
          origin_id: data['origin_id'],
          topics: data['topics'],
          author: data['author'],
          quote: data['quote']
        )

        # LightofDay::FavQs::Entity::Inspiration.new(
        #   id: nil,
        #   origin_id: inspiration_hash[:origin_id],
        #   topics: inspiration_hash[:topics],
        #   author: inspiration_hash[:author],
        #   quote: inspiration_hash[:quote]
        # )
      end

      def create_view(data, inspiration)
        LightofDay::Unsplash::Entity::View.new(
          # id: data['id'].to_i,
          id: nil,
          origin_id: data['origin_id'],
          topics: data['topics'],
          width: data['width'].to_i,
          height: data['height'].to_i,
          urls: data['urls'],
          urls_small: data['urls_small'],
          creator_name: data['creator_name'],
          creator_bio: data['creator_bio'],
          creator_image: data['creator_image'],
          inspiration:
        )
      end
    end
  end
end
