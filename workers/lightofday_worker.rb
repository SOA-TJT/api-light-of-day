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
  shoryuken_options queue: config.FAVORITE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    data = JSON.parse(request)
    puts 'data:',data['input']
    LightofDay::Repository::Store.new.parse_lightofday(data['input'])
    # data = LightofDay::Representer::ViewLightofDay
    #   .new(Struct.new).from_json(request)
    # puts 'data:', data
    # result = LightofDay::Repository::For.entity(data)
    # result = LightofDay::Repository::For.entity(data['input']).create(data['input'])
    # LightofDay::Unsplash::ViewMapper
    #             .new(LightofDay::App.config.UNSPLASH_SECRETS_KEY,
    #                  data['topic_id']).find_a_photo
    # puts 'result:', result
  rescue StandardError
    puts 'perform error'
  end
end

# Shoryuken worker class to clone repos in parallel
class SubscribeLightofdayWorker
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
  shoryuken_options queue: config.SUBSCRIBE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    data = JSON.parse(request)
    subscribe(data['email']) if data['action'] == 'subscribe'
  rescue StandardError => e
    puts "Action not success. Error message: #{e}"
  end

  def subscribe(email)
    puts email
    LightofDay::Messaging::Email
      .new
      .subscribe(email)
  end

  def generate_email
    lightofday = LightofDay::Unsplash::ViewMapper
                 .new(LightofDay::App.config.UNSPLASH_SECRETS_KEY,
                      data['topic_id']).find_a_photo
    puts lightofday
  end

  def send_email(email, body)
    LightofDay::Messaging::Email.new.send(email, body)
  end
end
