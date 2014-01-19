require 'spec_helper'

describe Vx::Worker::Timeout do
  let(:exit_code) { 0 }
  let(:app)       { ->(_) { exit_code } }
  let(:env)       { OpenStruct.new }
  let(:mid)       { described_class.new app }

  subject { mid.call env }

  it { should eq 0 }

  context "when timeout happened" do
    let(:app) { ->(_) { sleep 1 ; exit_code } }

    before do
      mock(mid)._timeout { 0.1 }
    end

    it "should raise" do
      expect {
        subject
      }.to raise_error(Timeout::Error)
    end
  end

end

