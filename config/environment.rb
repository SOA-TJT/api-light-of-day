# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'figaro'
require 'sequel'
require 'rack/session'
require 'rack/cache'
require 'redis-rack-cache'

module LightofDay
  # Configuration for the App
  class App < Roda
    # CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    # UNSPLAH_TOKEN = CONFIG['UNSPLASH_SECRETS_KEY']
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment:,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      def self.config = Figaro.env

      # Setup Cacheing mechanism
      configure :development do
        use Rack::Cache,
            verbose: true,
            metastore: 'file:_cache/rack/meta',
            entitystore: 'file:_cache/rack/body'
      end

      configure :production do
        use Rack::Cache,
            verbose: true,
            metastore: "#{config.REDISCLOUD_URL}/0/metastore",
            entitystore: "#{config.REDISCLOUD_URL}/0/entitystore"
      end

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      # Database Setup
      DB = Sequel.connect(ENV.fetch('DATABASE_URL')) # rubocop:disable Lint/ConstantDefinitionInBlock
      def self.DB = DB # rubocop:disable Naming/MethodName
    end
  end
end
