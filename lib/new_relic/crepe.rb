require 'new_relic/agent/instrumentation/controller_instrumentation'
require 'new_relic/crepe/version'

module NewRelic
  module Agent
    module Instrumentation
      class Crepe
        include ControllerInstrumentation

        def initialize(app)
          @app = app
        end

        def call(env)
          @env = env
          @newrelic_request = ::Rack::Request.new(@env)

          trace_options = {
            :category => :sinatra,
            :request  => @newrelic_request,
            :params   => @newrelic_request.params
          }

          perform_action_with_newrelic_trace(trace_options) do
            @app_response = @app.call(@env)
            NewRelic::Agent.set_transaction_name(transaction_name)
            return @app_response
          end
        end

        def request_method
          @env['REQUEST_METHOD']
        end

        def request_path
          @env['PATH_INFO'].dup.tap do |path|
            @env['rack.routing_args'].except(:format).each do |param, arg|
              path.sub!(arg, ":#{param}")
            end
          end
        end

        def request_format
          if @format = @env['rack.routing_args'][:format]
            ".#{@format}"
          end
        end

        def transaction_name
          "#{request_method} #{request_path}#{request_format}"
        end
      end
    end
  end
end
