# frozen_string_literal: true

require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'
require_relative '../../../helpers/spec_helper'

describe 'Intergration Test of Unsplash API , FavQs API and database ' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_unsplash
  end
  after do
    VcrHelper.eject_vcr
  end
  describe 'Retrieve and Store Views' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save Views from Unsplash and inspiration from FavQs API to database' do
      view = LightofDay::Unsplash::ViewMapper
             .new(UNSPLAH_TOKEN, TOPIC_ID)
             .find_a_photo
      # inspiration = LightofDay::FavQs::InspirationMapper.new.find_random
      rebuilt = LightofDay::Repository::For.entity(view).create(view)

      _(rebuilt.width).must_equal(view.width)
      _(rebuilt.height).must_equal(view.height)
      _(rebuilt.topics).must_equal(view.topics)
      _(rebuilt.inspiration).must_be_kind_of(LightofDay::FavQs::Entity::Inspiration)
    end
  end
end
