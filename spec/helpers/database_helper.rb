# frozen_string_literal: true

# Helper to clean database during tests runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    LightofDay::App.DB.run('PRAGMA foreign_keys =OFF')
    LightofDay::Database::InspirationOrm.map(&:destroy)
    LightofDay::Database::ViewOrm.map(&:destroy)
    LightofDay::App.DB.run('PRAGMA foreign_keys =ON')
  end
end
