require 'spec_helper'

describe Vx::Worker::Local do
  let(:options) { { } }
  let(:job)     { create :job, options }
  let(:local)   { described_class.new job }
  subject { local }

  context "perform" do
    subject { local.perform }

    before do
      Vx::Worker.config.run = "local"
    end

    it { should eq 0 }

    context "when fail before_script" do
      let(:options) { { before_script: "/bin/false" } }
      it { should eq(-1) }
    end

    context "when fail script" do
      let(:options) { { script: "/bin/false" } }
      it { should satisfy { |n| [1,127].include?(n) } }
    end
  end

end
