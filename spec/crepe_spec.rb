# encoding: utf-8
require 'spec_helper'
require 'new_relic/crepe'

describe NewRelic::Agent::Instrumentation::Crepe do
  let(:app) do
    Class.new(Crepe::API) do
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

  it 'correctly sets transaction name' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET  ⁄ hello ⁄ :name', category: :uri)
    get '/hello/david'
  end

  it 'does not replace namespaces in the transaction name' do
    expect(NewRelic::Agent).to receive(:set_transaction_name).with('GET  ⁄ v1 ⁄ hello', category: :uri)
    get '/v1/hello'
  end

  it 'ignores transactions that are 404s' do
    expect(NewRelic::Agent).to receive(:ignore_transaction)

    get '/bogus'
  end

  it 'captures parameters' do
    txn = double
    expect(txn).to receive(:merge_request_parameters).with({
      name: 'david',
      'password' => 'secret'
    })

    allow(txn).to receive(:make_transaction_name)
    allow(txn).to receive(:name_last_frame)
    allow(txn).to receive(:set_overriding_transaction_name)

    allow(NewRelic::Agent::Transaction).to receive(:tl_current).and_return(txn)

    get '/hello/david', password: 'secret'
  end
end
