# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start
SimpleCov.root('../')

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

# require_relative '../lib/unsplash_api'
require_relative '../../require_app'
require_app

TOPIC_ID = 'xjPR4hlkBGA'
VIEW_ID = 'JJSIg8xwKkQ'
UNSPLAH_TOKEN = LightofDay::App.config.UNSPLASH_SECRETS_KEY
output_path = File.expand_path('../fixtures/unsplash_results.yml', __dir__)
CORRECT = YAML.unsafe_load(File.read(output_path))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'unsplash_api'
