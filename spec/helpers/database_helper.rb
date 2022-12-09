# frozen_string_literal: true

# Helper to clean database during tests runs
module DatabaseHelper
  def self.setup_data
    LightofDay::Database::ViewOrm.create(
      origin_id: 'JJSIg8xwKkQ',
      topics: 'test_topic',
      urls: 'test_urls',
      creator_name: 'test_name',
      creator_bio: 'test_bio',
      creator_image: 'test_img',
      urls_small: 'test_urlsmall'
    )
    LightofDay::Database::InspirationOrm.create(
      origin_id: 1,
      topics: 'test_topic',
      author: 'test_author',
      quote: 'test_quote'
    )
  end

  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    LightofDay::App.DB.run('PRAGMA foreign_keys =OFF')
    LightofDay::Database::InspirationOrm.map(&:destroy)
    LightofDay::Database::ViewOrm.map(&:destroy)
    LightofDay::App.DB.run('PRAGMA foreign_keys =ON')
  end
end
