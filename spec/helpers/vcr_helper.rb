# frozen_string_literal: true

require 'vcr'
require 'webmock'

# setup VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'unsplash_api'
  def self.configure_vcr_for_unsplash(recording: :new_episodes)
    VCR.configure do |c|
      c.filter_sensitive_data('<UNSPLAH_TOKEN>') { UNSPLAH_TOKEN }
      c.filter_sensitive_data('<UNSPLAH_TOKEN_ESC>') { CGI.escape(UNSPLAH_TOKEN) }
    end
    VCR.insert_cassette(
      CASSETTE_FILE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      vcr_config.ignore_hosts 'sqs.us-east-1.amazonaws.com'
      vcr_config.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
