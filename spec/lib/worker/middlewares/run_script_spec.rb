require 'spec_helper'
require 'vx/common/spawn'

describe Vx::Worker::RunScript do
  let(:exit_code)     { 0 }
  let(:app)           { ->(_) { exit_code } }
  let(:script)        { "echo script" }
  let(:before_script) { "echo before_script" }
  let(:after_script)  { "echo after_script" }
  let(:job)           { create :job,
                          script: script,
                          before_script: before_script,
                          after_script: after_script }
  let(:env)           { OpenStruct.new job: job }
  let(:mid)           { described_class.new app }
  let(:connector_mid) { Vx::Worker::StartConnector.new(mid) }

  subject { connector_mid.call env }

  shared_examples "run script" do

    it "should be" do
      expect(subject).to eq 0
      job.release
      expect(all_job_log_output).to match("script")
      expect(all_job_log_output).to match("after_script")
    end

    context "when script failed" do
      let(:script) { "false" }
      it "should be" do
        expect(subject).to eq(1)
        job.release
        expect(all_job_log_output).to match("after_script")
      end
    end

    context "when  before_script failed" do
      let(:before_script) { "false" }
      it "should be" do
        expect(subject).to eq(-1)
        job.release
        expect(all_job_log_output).to match("after_script")
      end
    end

    it "should raise error when read timeout happened" do
      job.message.script = 'sleep 3'
      mock(mid).default_read_timeout { 0.1 }

      expect{ subject }.to raise_error(
        ::Vx::Common::Spawn::ReadTimeoutError,
        "No output has been received in the last 0.1 seconds"
      )
    end

    it "should raise error when job read timeout happened" do
      job.message.script = 'sleep 3'
      job.message.read_timeout = 0.1

      expect{ subject }.to raise_error(
        ::Vx::Common::Spawn::ReadTimeoutError,
        "No output has been received in the last 0.1 seconds"
      )
    end
  end

  context "local connector" do
    before do
      stub(Vx::Worker.config).run { :local }
    end

    it_should_behave_like "run script"
  end

  context "docker connector", docker: true do
    before do
      stub(Vx::Worker.config).run { :docker }
    end

    it_should_behave_like "run script"
  end
end

