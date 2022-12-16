# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class FindLightofdayWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    data = JSON.parse(request)
    # project = LightofDay::Representer::ViewLightofDay
    #   .new(OpenStruct.new).from_json(request)
    LightofDay::Unsplash::ViewMapper
      .new(App.config.UNSPLASH_SECRETS_KEY,
           data['topic_id']).find_a_photo
  # rescue LightofDay::GitRepo::Errors::CannotOverwriteLocalGitRepo
  rescue StandardError
    puts 'CLONE EXISTS -- ignoring request'
  end
end
