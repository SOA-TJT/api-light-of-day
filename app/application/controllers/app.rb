# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'json'

module LightofDay
  # Web App
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :common_logger, $stderr
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :status_handler

    # use Rack::MethodOverride
    # status_handler(404) do
    #   view('404')
    # end

    route do |routing|
      response['Content-Type'] = 'application/json'

      topics_mapper = Service::ListTopics.new
      topics_result = topics_mapper.call('normal')
      # if topics_result.failure?
      #   flash[:error] = topics_result.failure
      #   view_topic = []
      # else
      #   topics_result = topics_result.value!
      #   view_topic = Views::TopicList.new(topics_result)
      # end

      # GET /
      routing.root do
        message = "Light of Day API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
        # view 'picktopic', locals: { topics: view_topic }
      end

      routing.on 'api/v1' do
        # for taylor
        routing.on 'topics', String do |sort_by|
          # GET /api/v1/topics?sort="default"
          routing.get do
            topics_result = topics_mapper.call(sort_by)
            if topics_result.failure?
              flash[:error] = topics_result.failure
              view_topic = []
            else
              topics_result = topics_result.value!
              view_topic = Views::TopicList.new(topics_result)
            end
            view 'picktopic', locals: { topics: view_topic }
          end
        end
        routing.on 'light-of-day' do
          routing.on 'random_view', String do |topic_slug|
            # GET /api/v1/light-of-day/random_view/{topic_slug}
            routing.get do
              result = Service::FindLightofDay.new.call(topic_slug)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::ViewLightofDay.new(
                result.value!.message
              ).to_json
            end
          end

          routing.is do
            # GET /api/v1/light-of-day?list={origin_ids}
            routing.get do
              list_req = Request::EncodedFavoriteList.new(routing.params)
              puts list_request: list_req
              result = Service::ListFavorite.new.call(list_request: list_req)
              puts result

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::FavoriteList.new(result.value!.message).to_json
            end
          end

          routing.on 'view' do
            routing.on String do |view_id|
              # POST /api/v1/light-of-day/view/{origin_id}
              routing.post do
                view_record = Service::ParseLightofday.new.call(routing.params['favorite'])
                # store lightofday to DB
                result = Service::StoreLightofDay.new.call(view_record)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::ViewLightofDay.new(result.value!.message).to_json
              end
              # GET /api/v1/light-of-day/view/{origin_id}
              routing.get do
                result = Service::GetLightofDay.new.call(view_id)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                puts result.value!
                Representer::ViewLightofDay.new(
                  result.value!.message
                ).to_json
              end
            end
          end
        end
      end
    end
  end
end
