require 'newrelic_rpm'
require 'new_relic/agent/parameter_filtering'
require 'pry'

module NewRelic
  module Agent
    module Instrumentation
      module Crepe
        extend self

        def handle_transaction(response, env)
          case response.first
          when 404
            ::NewRelic::Agent.ignore_transaction
          else
            name_transaction(env)
            capture_params(env)
          end
        end

        private

        def name_transaction(env)
          ::NewRelic::Agent.set_transaction_name(name_for_transaction(env))
        end

        def name_for_transaction(env)
          routing_args = env['rack.routing_args'] || {}

          request_path = env['PATH_INFO'].dup.tap do |path|
            routing_args.except(:format, :namespace).each do |param, arg|
              path.sub!(arg.to_s, ":#{param}")
            end
          end

          request_method = env['REQUEST_METHOD']
          request_format = routing_args[:format]

          "#{request_method} #{request_path}"
        end

        def capture_params(env)
          txn = Transaction.tl_current

          params = env['rack.request.query_hash'] || {}
          params = params.except(:format, :namespace)
          params = ParameterFiltering.apply_filters(env, params)
          params = filter_params(params)

          txn.filtered_params = params
          txn.merge_request_parameters(params)
        end

        def filter_params(params)
          params.each do |k, v|
            params[k] = '[FILTERED]' if filtered_params.include?(k.to_s)
          end
        end

        def filtered_params
          NewRelic::Agent.config[:filtered_params]
        end
      end
    end
  end
end

DependencyDetection.defer do
  named :crepe

  depends_on do
    defined?(::Crepe) && !NewRelic::Agent.config[:disable_crepe]
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Crepe instrumentation'
    instrument_call
  end

  def instrument_call
    class << ::Crepe::API
      def call_with_new_relic(env)
        begin
          response = call_without_new_relic(env)
        ensure
          begin
            ::NewRelic::Agent::Instrumentation::Crepe.handle_transaction(response, env)
          rescue => e
            ::NewRelic::Agent.logger.warn('Error in Crepe instrumentation', e)
          end
        end

        response
      end

      alias_method :call_without_new_relic, :call
      alias_method :call, :call_with_new_relic
    end
  end

end

DependencyDetection.detect!
