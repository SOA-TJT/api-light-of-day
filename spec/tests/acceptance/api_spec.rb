# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'
require 'uri'
def app
  LightofDay::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_unsplash
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'List Unsplash Topics' do
    it 'Happy: should be able to get unsplash topic list' do
      # LightofDay::Service::FindTopics.new.call

      get '/api/v1/topics?sort=default'
      _(last_response.status).must_equal 200
      topics = JSON.parse last_response.body
      _(topics['topics'].count).must_equal 11
      first_topic = topics['topics'].first
      _(first_topic['topic_id']).must_be_kind_of(String)
      _(first_topic['title']).must_be_kind_of(String)
      _(first_topic['slug']).must_be_kind_of(String)
      _(first_topic['starts_at']).must_be_kind_of(String)
      _(first_topic['total_photos']).must_be_kind_of(Integer)
      _(first_topic['preview_photos'][0]['urls']).must_be_kind_of(Hash)
    end
  end
  describe 'Get a group of view & quote' do
    it 'Happy: should be able to get view & quote with correct topic' do
      # LightofDay::Service::FindLightofDay.new.call('nature')

      get '/api/v1/light-of-day/random_view/nature'
      _(last_response.status).must_equal 200
      view = JSON.parse last_response.body
      _(view['origin_id']).must_be_kind_of(String)
      _(view['width']).must_be_kind_of(Integer)
      _(view['height']).must_be_kind_of(Integer)
      _(view['creator_name']).must_be_kind_of(String)
      _(view['urls']).must_be_kind_of(String)
      _(view['urls_small']).must_be_kind_of(String)
      inspiration = view['inspiration']
      _(inspiration['origin_id']).must_be_kind_of(Integer)
      _(inspiration['quote']).must_be_kind_of(String)
    end
    it 'Happy: should be able to get view & quote with correct origin_id' do
      view_id = 'BtRCU_xCimY'
      get "/api/v1/light-of-day/view/#{view_id}"
      _(last_response.status).must_equal 200
      view = JSON.parse last_response.body
      _(view['origin_id']).must_be_kind_of(String)
      _(view['width']).must_be_kind_of(Integer)
      _(view['height']).must_be_kind_of(Integer)
      _(view['creator_name']).must_be_kind_of(String)
      _(view['urls']).must_be_kind_of(String)
      _(view['urls_small']).must_be_kind_of(String)
      inspiration = view['inspiration']
      _(inspiration['origin_id']).must_be_kind_of(Integer)
      _(inspiration['quote']).must_be_kind_of(String)
    end
  end
  describe 'Get a list of view & quote' do
    it 'Happy: should be able to get view & quote with correct origin_ids' do
      view_ids = 'BtRCU_xCimY,feog_fjkne'
      get "/api/v1/light-of-day?list=#{view_ids}"
      _(last_response.status).must_equal 200
      views = (JSON.parse last_response.body)['lightofdays']
      _(views).must_be_kind_of(Array)
      view = views[0]
      _(view['origin_id']).must_be_kind_of(String)
      _(view['width']).must_be_kind_of(Integer)
      _(view['height']).must_be_kind_of(Integer)
      _(view['creator_name']).must_be_kind_of(String)
      _(view['urls']).must_be_kind_of(String)
      _(view['urls_small']).must_be_kind_of(String)
      inspiration = view['inspiration']
      _(inspiration['origin_id']).must_be_kind_of(Integer)
      _(inspiration['quote']).must_be_kind_of(String)
    end
  end
#   describe 'Save a group of view & quote' do
#     it 'Happy: should be able to save view & quote' do
#       random_id = 'adaf_adfg'
#       query_list = "id=''&origin_id=#{random_id}&width=4&height=4&creator_name=Lisa&creator_image=https://images&creator_bio=Hi&topics=nature&urls=https://images&urls_small=https://images&inspiration={\"origin_id\":613,\"quote\":\"main live.\",\"author\":\"George\",\"topics\":\"christmas\"}"
#       url = "/api/v1/light-of-day/view?#{query_list}"
#       post url
#       _(last_response.status).must_equal 201
#     end
#   end
end
