require 'spec_helper'

describe Vx::Worker::Docker, docker: true do
  let(:options) { { } }
  let(:job)     { create :job, options }
  let(:local)   { described_class.new job }
  subject { local }

  context "perform" do
    subject { local.perform }
    it { should eq 0 }

    before do
      Vx::Worker.config.run = "docker"
    end

    context "when fail before_script" do
      let(:options) { { before_script: "false" } }
      it { should eq(-1) }
    end

    context "when fail script" do
      let(:options) { { script: "false" } }
      it { should eq(1) }
    end
  end

end
