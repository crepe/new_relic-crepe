require 'spec_helper'
require 'new_relic/crepe'

describe NewRelic::Agent::Instrumentation::Crepe do
  let(:app) do
    Class.new(Crepe::API) do
      get '/hello/:name' do
        # For some reason, this doesn't get set in the test environment.
        request.env['REQUEST_PATH'] = "/hello/#{params[:name]}"
        { hello: params[:name] }
      end

      namespace :v1 do
        get :hello do
          request.env['REQUEST_PATH'] = "/v1/hello"
          { hello: :world }
        end
      end
    end
  end

  it 'traces actions with New Relic' do
    expect_any_instance_of(NewRelic::Agent::Instrumentation::Crepe).to(
      receive(:perform_action_with_newrelic_trace).and_yield
    )

    get '/hello/david'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to   eq('{"hello":"david"}')
  end

  it 'correctly sets transaction name' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET /hello/:name')
    get '/hello/david'
  end

  it 'does not replace namespaces in the transaction name' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET /v1/hello')
    get '/v1/hello'
  end

  it 'ignores transactions that are 404s' do
    txn = double(ignore!: true)
    expect(NewRelic::Agent::Transaction).to receive(:tl_current).and_return(txn)

    get '/bogus'
  end
end
