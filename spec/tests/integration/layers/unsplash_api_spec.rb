# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'

describe 'Tests Unsplash API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<UNSPLAH_TOKEN>') { UNSPLAH_TOKEN }
    c.filter_sensitive_data('<UNSPLAH_TOKEN_ESC>') { CGI.escape(UNSPLAH_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Photos information' do
    it '😃: should provide view attributes' do
      view =
        LightofDay::Unsplash::ViewMapper
        .new(UNSPLAH_TOKEN, TOPIC_ID)
        .find_a_photo
      _(view.width).wont_be_nil
      _(view.height).wont_be_nil
      _(view.urls).wont_be_nil
      _(view.creator_name).wont_be_nil
    end

    it '😭: should raise exception when unauthorized' do
      _(proc do
        LightofDay::Unsplash::ViewMapper
        .new('BAD_TOKEN', TOPIC_ID)
        .find_a_photo
      end).must_raise LightofDay::GeneralApi::Response::Unauthorized
    end
  end

  describe 'Topics information' do
    it '😃: should identify topics' do
      topics = LightofDay::TopicMapper
               .new(UNSPLAH_TOKEN)
               .find_all_topics
      _(topics.count).wont_be_nil
      # _(topics.first.topic_id).must_equal CORRECT['topics'][1]['topic_id']
      # _(topics.last.topic_id).must_equal CORRECT['topics'][24]['topic_id']
    end
    it '😭: should raise exception when unauthorized' do
      _(proc do
        LightofDay::TopicMapper
        .new('BAD_TOKEN')
        .find_all_topics
      end).must_raise LightofDay::GeneralApi::Response::Unauthorized
    end
  end
end
