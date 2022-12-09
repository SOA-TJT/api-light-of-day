# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

require 'ostruct'

describe 'LightofDay Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_unsplash(recording: :none)
    DatabaseHelper.wipe_database
    DatabaseHelper.setup_data
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'List Favorite' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return lightofday that are in db' do
      # GIVEN: a valid view exists locally
      param = {}
      param['list'] = VIEW_ID
      list_req = LightofDay::Request::EncodedFavoriteList.new(param)

      # WHEN: we request a list of all watched projects
      result = LightofDay::Service::ListFavorite.new.call(list_request: list_req)

      # THEN: we should see our project in the resulting list
      _(result.success?).must_equal true
    end

    it 'HAPPY: should not return lightofday since they are not in favorite list' do
      # GIVEN: a invalid view_id whitch do not be stored in db
      param = {}
      param['list'] = 'wrong_id'
      list_req = LightofDay::Request::EncodedFavoriteList.new(param)

      # WHEN: we request a list of all watched projects
      result = LightofDay::Service::ListFavorite.new.call(list_request: list_req)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      lightofdays = result.value!.message.lightofdays
      _(lightofdays.count).must_equal 0
    end
  end
end
