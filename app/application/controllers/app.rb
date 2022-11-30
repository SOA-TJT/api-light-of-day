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

        routing.on 'favorite-list' do
          # routing.is do
          #   # GET /api/v1/light-of-day?list={origin_ids}
          #   routing.get do
          #     list_req = Request::EncodedFavoriteList.new(routing.params)
          #     result = Service::ListFavorite.new.call(list_request: list_req)

          #     if result.failure?
          #       failed = Representer::HttpResponse.new(result.failure)
          #       routing.halt failed.http_status_code, failed.to_json
          #     end

          #     http_response = Representer::HttpResponse.new(result.value!)
          #     response.status = http_response.http_status_code
          #     Representer::FavoriteList.new(result.value!.message).to_json
          #   end
          # end
        end

        routing.on 'light-of-day' do
          # routing.is do
          #   # POST /light-of-day/
          #   routing.post do
          #     topic_id = routing.params['topic_id']

          #     slug = topics_mapper.find_slug(topic_id)
          #     if slug.failure?
          #       flash[:error] = slug.failure
          #       routing.redirect '/'
          #     end
          #     slug = slug.value!
          #     routing.redirect "light-of-day/topic/#{slug}"
          #   end
          # end

          routing.on 'random_view', String do |topic_slug|
            # GET /api/v1/light-of-day/random_view/{topic_slug}
            routing.get do
              topic_data = topics_mapper.find_topic(topic_slug)
              topic_data = topic_data.value!
              view_data = Service::FindLightofDay.new.call(topic_data)

              if view_data.failure?
                flash[:error] = view_data.failure
                view_lightofday = []
              else
                view_data = view_data.value!
                view_lightofday = Views::LightofDay.new(view_data)
              end

              view 'view', locals: { view: view_lightofday, is_saved: false }
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
            routing.on String do |view_id|
              # POST /api/v1/light-of-day/view/{origin_id}
              routing.post do
                result = Service::ParseLightofday.new.call(routing.params['favorite'])

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
                # path_request = Request::ProjectPath.new(
                # owner_name, project_name, request
                # )

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
