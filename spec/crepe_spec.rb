require 'spec_helper'
require 'new_relic/crepe'

describe NewRelic::Agent::Instrumentation::Crepe do
  let(:app) do
    Class.new(Crepe::API) do
      use NewRelic::Agent::Instrumentation::Crepe

      get '/:name' do
        { hello: params[:name] }
      end
    end
  end

  it 'traces actions with New Relic' do
    NewRelic::Agent::Instrumentation::Crepe.any_instance.should_receive(:perform_action_with_newrelic_trace).and_yield

    get '/david'

    last_response.status.should == 200
    last_response.body.should == '{"hello":"david"}'
  end

end

