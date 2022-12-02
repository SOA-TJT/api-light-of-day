# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'json'

module LightofDay
  # Web App
  class App < Roda
    # plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    # plugin :assets, path: 'app/presentation/assets', css: 'style.css', js: 'main.js'

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
          Response::ApiResult.new(status: :ok, message:)
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
        routing.on 'topics' do
          routing.is do
            routing.get do
              list_req = Request::EncodedTopics.new(routing.params)
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
                result = Service::FindLightofDay.new.call(view_id)

                # view_record = Service::ParseLightofday.new.call(routing.params['favorite'])
                puts result
                puts JSON.parse(result.value!)
                puts result.value!.message
                view_record = Service::ParseLightofday.new.call(result.value!.message)
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
    #   topics_mapper = Service::ListTopics.new
    #   topics_result = topics_mapper.call('normal')
    #   if topics_result.failure?
    #     flash[:error] = topics_result.failure
    #     view_topic = []
    #   else
    #     topics_result = topics_result.value!
    #     view_topic = Views::TopicList.new(topics_result)
    #   end

    #   # GET /
    #   routing.root do
    #     view 'picktopic', locals: { topics: view_topic }
    #   end

    #   # GET /list_topics/{sort_by}
    #   routing.on 'list_topics', String do |sort_by|
    #     routing.get do
    #       topics_result = topics_mapper.call(sort_by)
    #       if topics_result.failure?
    #         flash[:error] = topics_result.failure
    #         view_topic = []
    #       else
    #         topics_result = topics_result.value!
    #         view_topic = Views::TopicList.new(topics_result)
    #       end
    #       view 'picktopic', locals: { topics: view_topic }
    #     end
    #   end

    #   routing.on 'favorite-list' do
    #     routing.is do
    #       session[:watching] ||= []
    #       # Load previously viewed Views
    #       result = Service::ListFavorite.new.call(session[:watching])
    #       if result.failure?
    #         flash[:error] = result.failure
    #         view_favorite_list = []
    #       else
    #         favorite_list = result.value!
    #         flash.now[:error] = 'Make some collections to get started' if favorite_list.none?

    #         session[:watching] = favorite_list.map(&:origin_id)
    #         view_favorite_list = Views::FavoritecList.new(favorite_list)
    #       end
    #       view 'favoritelist', locals: { favoriteList: view_favorite_list }
    #     end
    #   end

    #   routing.on 'light-of-day' do
    #     routing.is do
    #       # POST /light-of-day/
    #       routing.post do
    #         topic_id = routing.params['topic_id']

    #         slug = topics_mapper.find_slug(topic_id)
    #         if slug.failure?
    #           flash[:error] = slug.failure
    #           routing.redirect '/'
    #         end
    #         slug = slug.value!
    #         routing.redirect "light-of-day/topic/#{slug}"
    #       end
    #     end

    #     routing.on 'topic', String do |topic_slug|
    #       # GET /light-of-day/topic/{topic}
    #       routing.get do
    #         topic_data = topics_mapper.find_topic(topic_slug)
    #         topic_data = topic_data.value!
    #         view_data = Service::FindLightofDay.new.call(topic_data)

    #         if view_data.failure?
    #           flash[:error] = view_data.failure
    #           view_lightofday = []
    #         else
    #           view_data = view_data.value!
    #           view_lightofday = Views::LightofDay.new(view_data)
    #         end

    #         view 'view', locals: { view: view_lightofday, is_saved: false }
    #       end
    #     end

    #     routing.on 'favorite' do
    #       routing.is do
    #         # POST /light-of-day/favorite/
    #         routing.post do
    #           view_record = Service::ParseLightofday.new.call(routing.params['favorite']).value!
    #           session[:watching] ||= []
    #           session[:watching].insert(0, view_record.origin_id).uniq!

    #           # store lightofday to DB
    #           lightofday_made = Service::StoreLightofDay.new.call(view_record)
    #           flash[:error] = lightofday_made.failure if lightofday_made.failure?

    #           view_id = routing.params['view_data']
    #           flash[:notice] = 'Add successfully to your favorite !'
    #           routing.redirect "favorite/#{view_id}"
    #         end
    #       end
    #       routing.on String do |view_id|
    #         # Delete /light-of-day/favorite/{view_id}
    #         routing.delete do
    #           origin_id = view_id.to_s
    #           session[:watching].delete(origin_id)
    #           routing.redirect '/favorite-list'
    #         end
    #         # GET /light-of-day/favorite/{view_id}
    #         routing.get do
    #           lightofday_get = Service::GetLightofDay.new.call(view_id)

    #           if lightofday_get.failure?
    #             flash[:error] = lightofday_get.failure
    #           else
    #             lightofday_data = lightofday_get.value!
    #             flash.now[:error] = 'Data not found' if lightofday_get.nil?
    #           end

    #           view_lightofday = Views::LightofDay.new(lightofday_data)
    #           view 'view', locals: { view: view_lightofday, is_saved: true }
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
