require 'spec_helper'

describe Vx::Worker do

  context ".perform" do
    let(:job) { create :job }
    let(:run) { :docker }
    subject { described_class.perform job, '/tmp' }

    before do
      described_class.configure do |c|
        c.run = run
      end
    end

    context "when run at :docker" do
      let(:run) { :docker }
      let(:docker) { 'docker' }
      before do
        mock(Vx::Worker::Docker).new(job, '/tmp') { docker }
        mock(docker).perform { true }
      end

      it { should be }
    end

    context "when run at :local" do
      let(:run) { :local }
      let(:local) { 'local' }
      before do
        mock(Vx::Worker::Local).new(job, '/tmp') { local }
        mock(local).perform { true }
      end

      it { should be }
    end
  end

end
