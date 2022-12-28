# frozen_string_literal: true

module LightofDay
  module Repository
    class Store
      def initialize
        @view_repo = Repository::For.klass(Unsplash::Entity::View)
      end

      def parse_lightofday(input)
        puts 'parse input:', input
        inspiration_record = create_inspiration(input['inspiration'])
        view_record = create_view(input, inspiration_record)
        # Success(view_record)
        puts 'view_record:', view_record
        Repository::For.entity(view_record).create(view_record)
      end

      def exists_locally(input)
        puts 'local:', input
        @view_repo.find_origin_id(input)
      end

      # help method
      def create_inspiration(data)
        # inspiration_hash = eval(data)

        LightofDay::FavQs::Entity::Inspiration.new(
          id: nil,
          origin_id: data['origin_id'],
          topics: data['topics'],
          author: data['author'],
          quote: data['quote']
        )
      end

      def create_view(data, inspiration)
        LightofDay::Unsplash::Entity::View.new(
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
