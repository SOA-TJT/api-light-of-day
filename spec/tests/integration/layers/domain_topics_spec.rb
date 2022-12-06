# frozen_string_literal: true

require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'
require_relative '../../../helpers/spec_helper'

describe 'Test Topic Mapper and Gateway' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_unsplash
    DatabaseHelper.wipe_database

    unsplash_topic = LightofDay::TopicMapper
                     .new(UNSPLAH_TOKEN)
                     .find_all_topics

    _(unsplash_topic).must_be_kind_of(Array)
  end

  after do
    VcrHelper.eject_vcr
  end

end
