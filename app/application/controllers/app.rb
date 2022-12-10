# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'json'

module LightofDay
  # Web App
  class App < Roda
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

      find_topics = Service::FindTopics.new.call
      # GET /
      routing.root do
        message = "Light of Day API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'topics' do
          # GET /api/v1/topics?sort="default"
          routing.is do
            routing.get do
              list_req = Request::EncodedTopics.new(routing.params)

              result = Service::ListTopics.new.with_step_args(
                retrieve_topics: [mapper: find_topics.value!]
              ).call(list_request: list_req)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Topics.new(result.value!.message).to_json
            end
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
              result = Service::ListFavorite.new.call(list_request: list_req)

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
            # POST /api/v1/light-of-day/view?list={base64_json_array_of_project_fullnames}
            routing.post do
              # need to be modify(next week)
              list_req = Request::EncodedView.new(routing.params).call
              view_record = Service::ParseLightofday.new.call(list_req.value!)

              # store lightofday to DB
              result = Service::StoreLightofDay.new.call(view_record.value!)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::ViewLightofDay.new(result.value!.message).to_json
            end

            routing.on String do |view_id|
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
