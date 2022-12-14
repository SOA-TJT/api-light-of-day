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
    plugin :caching
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

        routing.on 'subscribe' do
          # GET /api/v1/subscribe?email={user_email}&topic={topic_id}
          routing.is do
            routing.post do
              subscribe_data = Request::SubscribeData.new(routing.params)
              result = Service::SubscribeEmail.new.call(subscribe_data)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Subscribe.new(result.value!.message).to_json
            end
          end
        end

        routing.on 'send' do
          # GET /api/v1/subscribe?email={user_email}&topic={topic_id}
          routing.is do
            routing.post do
              subscribe_data = Request::SubscribeData.new(routing.params)
              result = Service::EmailLightOfDay.new.call(subscribe_data)
              # result = Service::FindLightofDay.new.call(routing.params['topic_id'])
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Subscribe.new(result.value!.message).to_json
            end
          end
        end
        routing.on 'focus' do
          routing.is String, String do |rest_time, work_time|
            # GET /api/v1/focus/resttime/worktime
            routing.get do
              # store focus to db
              result = Service::StoreFocus.new.call(
                work_time, rest_time
              )
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Focus.new(result.value!.message).to_json
            end
          end
          routing.on 'week-statistic' do
            routing.get do
              # GET /api/v1/focus/week-statistic
              result = Service::AnalyzeFocus.new.call

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end
              puts result.value!
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::DailyFocuses.new(result.value!.message).to_json
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
              response.cache_control public: true, max_age: 300
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
              request_id = [request.env, request.path, Time.now.to_f].hash

              list_req = Request::EncodedView.new(routing.params).call
              # view_record = Service::ParseLightofday.new.call(list_req.value!)

              # store lightofday to DB
              result = Service::StoreLightofDay.new.call(
                requested: list_req.value!,
                request_id:,
                config: App.config
              )
              puts 'view_record:', result

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
                response.cache_control public: true, max_age: 300

                result = Service::GetLightofDay.new.call(view_id)

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
          end
        end
      end
    end
  end
end
