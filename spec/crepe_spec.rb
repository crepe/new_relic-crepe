require 'spec_helper'
require 'new_relic/crepe'

describe NewRelic::Agent::Instrumentation::Crepe do
  let(:app) do
    Class.new(Crepe::API) do
      # For some reason, this doesn't get set in the test environment.
      before { request.env['REQUEST_PATH'] = request.path }

      get '/hello/:name' do
        { hello: params[:name] }
      end

      namespace :v1 do
        get :hello do
          { hello: :world }
        end
      end
    end
  end

  before do
    allow(NewRelic::Agent.config).to receive(:[]).
                                     with(:filtered_params).
                                     and_return(['password'])
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
    expect(NewRelic::Agent).to receive(:ignore_transaction)

    get '/bogus'
  end

  it 'filters parameters' do
    txn = double
    expect(txn).to receive(:filtered_params=).with("password" => "[FILTERED]")
    expect(txn).to receive(:merge_request_parameters).with("password" => "[FILTERED]")

    allow(txn).to receive(:make_transaction_name)
    allow(txn).to receive(:name_last_frame)
    allow(txn).to receive(:set_overriding_transaction_name)

    allow(NewRelic::Agent::Transaction).to receive(:tl_current).and_return(txn)

    get '/hello/david', password: 'hi'
  end
end
