require 'spec_helper'

describe Vx::Worker::Job do
  let(:message) { create :message, 'PerformJob' }
  let(:job)     { described_class.new message   }

  subject { job }

  context "just created" do
    its(:message)        { should eq message }
    its(:output)         { should be_an_instance_of(Vx::Common::OutputBuffer) }
    its(:output_counter) { should eq 0 }
  end

  context "publish_job_log_message" do
    let(:data) { 'log' }
    subject { job.publish_job_log_message data }

    it { should be_an_instance_of(Vx::Message::JobLog) }
    its(:job_id)   { should eq job.message.job_id }
    its(:build_id) { should eq job.message.id     }
    its(:tm)       { should eq 1 }
    its(:log)      { should eq data }

    it "should increment counter" do
      expect {
        subject
      }.to change(job, :output_counter).by(1)
    end
  end

  context "add_to_output" do
    let(:data)     { 'data' }
    let(:messages) { Vx::Worker::JobLogsConsumer.messages }
    subject do
      job.add_to_output(data)
      job.output.flush
      job
    end

    it "should delivery message" do
      expect {
        subject
      }.to change(messages, :size).by(1)
      expect(messages.first.log).to eq data
    end

    it "should increment output_counter" do
      expect {
        subject
      }.to change(job, :output_counter).by(1)
      expect(messages.first.tm).to eq 1
    end
  end

  context "add_command_to_output" do
    let(:data)     { 'data' }
    let(:messages) { Vx::Worker::JobLogsConsumer.messages }
    subject do
      job.add_command_to_output(data)
      job.output.flush
      job
    end

    it "should delivery message" do
      expect {
        subject
      }.to change(messages, :size).by(1)
      expect(messages.first.log).to eq "$ #{data}\n"
    end

    it "should increment output_counter" do
      expect {
        subject
      }.to change(job, :output_counter).by(1)
      expect(messages.first.tm).to eq 1
    end
  end

  context "add_trace_to_output" do
    let(:data)     { 'data' }
    let(:messages) { Vx::Worker::JobLogsConsumer.messages }
    subject do
      job.add_trace_to_output(data)
      job.output.flush
      job
    end

    it "should delivery message" do
      expect {
        subject
      }.to change(messages, :size).by(1)
      expect(messages.first.log).to eq " ===> #{data}\n"
    end

    it "should increment output_counter" do
      expect {
        subject
      }.to change(job, :output_counter).by(1)
      expect(messages.first.tm).to eq 1
    end
  end

end
