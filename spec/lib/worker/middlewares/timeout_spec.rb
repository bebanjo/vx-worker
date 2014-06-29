require 'spec_helper'

describe Vx::Worker::Timeout do
  let(:exit_code) { 0 }
  let(:app)       { ->(_) { exit_code } }
  let(:env)       { OpenStruct.new(job: OpenStruct.new) }
  let(:mid)       { described_class.new app }

  subject { mid.call env }

  it { should eq 0 }

  it "should raise error when timeout happened" do
    app = ->(_) { sleep 1 }
    mid = described_class.new(app)
    mock(mid).default_timeout { 0.1 }

    expect {
      mid.call env
    }.to raise_error(Timeout::Error)
  end

  it "should raise error when job timeout happened" do
    env.job.timeout_value = 0.1
    app = ->(_) { sleep 1 }
    mid = described_class.new(app)

    expect {
      mid.call env
    }.to raise_error(Timeout::Error)
  end

end

