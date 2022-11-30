# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module LightofDay
  module Representer
    # Representer for HTTP response information
    # Usage:
    #   result = Result.new(:not_found, 'resource not found')
    #   HttpResponseRepresenter.new(result).to_json
    #   HttpResponseRepresenter.new(result).http_status_code
    class HttpResponse < Roar::Decorator
      include Roar::JSON

      property :status
      property :message

      HTTP_CODE = {
        ok: 200,
        created: 201,
        processing: 202,
        no_content: 204,

        bad_request: 400,
        forbidden: 403,
        not_found: 404,
        conflict: 409,
        cannot_process: 422,

        internal_error: 500,
        bad_gateway: 502,
        service_unavailable: 503
      }.freeze

      def http_status_code
        HTTP_CODE[represented.status]
      end
    end
  end
end
