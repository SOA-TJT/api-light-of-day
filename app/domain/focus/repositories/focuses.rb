# frozen_string_literal: true

module LightofDay
  module Repository
    # mapping from Dbs Data from orms
    class Focuses
      def self.find_id(id)
        rebuild_entity Database::FocusOrm.first(id:)
      end

      def self.find_ssid(ssid)
        rebuild_entity Database::FocusOrm.first(ssid:)
      end

      def self.create(entity)
        Database::FocusOrm.create(entity.to_attr_hash)
      end

      def self.find_last7
        Database::FocusOrm
          .where(Sequel[:date] > Date.today - 7).all.map { |db_focus| rebuild_entity(db_focus) }
      end

      def self.find
        Database::FocusOrm.all.map { |db_focus| rebuild_entity(db_focus) }
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        OwnDb::Entity::Focus.new(
          id: db_record.id,
          ssid: db_record.ssid,
          uuid: db_record.uuid,
          rest_time: db_record.rest_time,
          work_time: db_record.work_time,
          date: db_record.date
        )
      end

      # def self.db_find_or_create(entity)
      #   Database::InspirationOrm.find_or_create(entity.to_attr_hash)
      # end
    end
  end
end
