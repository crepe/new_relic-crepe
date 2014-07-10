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

      version :v1, with: :header, vendor: 'myapp' do
        get :hello do
          request.env['REQUEST_PATH'] = "/hello"
          { hello: :world }
        end
      end

      version :v2 do
        get :hello do
          request.env['REQUEST_PATH'] = "/v2/hello"
          { hello: :World }
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

  it 'correctly sets transaction name when not versioned' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET /hello/:name')
    get '/hello/david'
  end

  it 'correctly sets the transaction name when versioned via a header' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET /v1/hello')
    get :hello, {}, 'HTTP_ACCEPT' => 'application/vnd.myapp-v1+json'
  end

  it 'correctly sets the transaction name when versioned via the path' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET /v2/hello')
    get '/v2/hello'
  end

end
