# encoding: utf-8

require 'newrelic_rpm'
require 'crepe'

module NewRelic
  module Agent
    module Instrumentation
      module Crepe
        extend self

        def handle_transaction(request, response)
          case response.first
          when 404
            ::NewRelic::Agent.ignore_transaction
          else
            name_transaction(request)
            merge_request_params(request)
          end
        end

        private

        def name_transaction(request)
          routing_args = request.env['rack.routing_args'] || {}

          request_path = request.path.dup.tap do |path|
            routing_args.except(:format, :namespace).each do |param, arg|
              path.sub!(arg.to_s, ":#{param}")
            end
          end

          # New Relic doesn't like normal slashes. That thing may look like a
          # weird, wonky backtick... But in the browser, it displays as a slash
          # with a small width (hence the outer spaces).
          name = "#{request.method} #{request_path.gsub('/', ' ⁄ ')}"

          ::NewRelic::Agent.set_transaction_name(name, category: :uri)
        end

        def merge_request_params(request)
          return unless Transaction.tl_current

          Transaction.tl_current.merge_request_parameters(request.params)
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
          request = ::Crepe::Request.new(env)
          response = call_without_new_relic(env)
        ensure
          begin
            ::NewRelic::Agent::Instrumentation::Crepe.handle_transaction(request, response)
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
