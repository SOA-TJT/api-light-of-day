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
        # lightofday_data = JSON.parse(input)
        puts input
        
        inspiration_record = create_inspiration(input['inspiration'])
        view_record = create_view(input, inspiration_record)
        # Success(lightofday)
        Success(view_record)
      end

      # help methods
      def create_inspiration(data)
        LightofDay::FavQs::Entity::Inspiration.new(
          id: data['id'].to_i,
          origin_id: data['origin_id'].to_i,
          topics: data['topics'],
          author: data['author'],
          quote: data['quote']
        )
      end

      def create_view(data, inspiration)
        LightofDay::Unsplash::Entity::View.new(
          id: data['id'].to_i,
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
