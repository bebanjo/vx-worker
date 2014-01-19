require 'spec_helper'

describe Vx::Worker::LogJob do
  let(:exit_code)   { 0 }
  let(:app)         { ->(_) { exit_code } }
  let(:job)         { create :job }
  let(:env)         { OpenStruct.new job: job }
  let(:mid)         { described_class.new app }

  subject { mid.call env }

  it { should eq 0 }

end

