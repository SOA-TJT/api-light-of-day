# frozen_string_literal: true

require_relative 'progress_publisher'

module LightofdayWorker
  # Reports job progress to client
  class JobReporter
    attr_accessor :lightofday

    def initialize(request_json, config)
      puts 'request_json', request_json
      store_request = LightofDay::Representer::StoreRequest
                      .new(OpenStruct.new)
                      .from_json(request_json)
      puts 'store_request:', store_request
      @lightofday = store_request.lightofday
      @publisher = ProgressPublisher.new(config, store_request.id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
