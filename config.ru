# frozen_string_literal: true

require 'faye'
require_relative 'require_app'
require_app

use Faye::RackAdapter, mount: '/faye', timeout: 25

# use Rack::Cors do
#   allow do
#     origins '*'
#     resource '*', headers: :any, methods: %i[get post]
#   end
# end

run LightofDay::App.freeze.app
