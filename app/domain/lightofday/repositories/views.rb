# frozen_string_literal: true

require_relative 'inspirations'

module LightofDay
  module Repository
    # Repository for Views
    class Views
      def self.all
        Database::ViewOrm.all.map { |db_view| rebuild_entity(db_view) }
      end

      def self.find(entity)
        puts "id:", entity.origin_id
        find_origin_id(entity.origin_id)
      end

      def self.find_origin_ids(origin_ids)
        origin_ids.map do |origin_id|
          find_origin_id(origin_id)
        end.compact
      end

      def self.find_origin_id(origin_id)
        db_record = Database::ViewOrm.first(origin_id:)
        rebuild_entity(db_record)
      end

      def self.find_id(id)
        db_record = Database::ViewOrm.first(id:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Views has already exists' if find(entity)

        db_view = PersistView.new(entity).call
        rebuild_entity(db_view)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Unsplash::Entity::View.new(
          db_record.to_hash.merge(
            inspiration: Inspirations.rebuild_entity(db_record.inspiration)
          )
        )
      end

      # help to upload the data to the Viewdatabase
      class PersistView
        def initialize(entity)
          @entity = entity
        end

        def create_view
          Database::ViewOrm.create(@entity.to_attr_hash)
        end

        # not sure this function is required
        def call
          inspiration = Inspirations.db_find_or_create(@entity.inspiration)
          create_view.tap do |db_view|
            db_view.update(inspiration:)
          end
        end
      end
    end
  end
end
