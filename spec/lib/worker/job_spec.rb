require 'spec_helper'

describe Vx::Worker::Job do
  let(:message) { create :message, 'PerformJob' }
  let(:job)     { described_class.new message   }

  subject { job }

  context "just created" do
    its(:message)         { should eq message }
    its(:output)          { should be_an_instance_of(Vx::Common::OutputBuffer) }
    its(:output_counter)  { should eq 0 }
    its(:instrumentation) { should eq(
      company_id:   "1",
      company_name: "company name",
      project_id:   "2",
      project_name: "project name",
      build_id:     "3",
      build_number:  4,
      job_id:       "5",
      job_number:    6,
      job_version:   1,
      job_id:       "5",
      build_id:     "3"
    ) }
  end

  it "should be timeout_value and read_timeout_value" do
    without = described_class.new(create :message, 'PerformJob')
    expect(without.timeout_value).to be_nil
    expect(without.read_timeout_value).to be_nil

    with = described_class.new(create :message, 'PerformJob', job_timeout: 10, job_read_timeout: 20)
    expect(with.timeout_value).to eq 10
    expect(with.read_timeout_value).to eq 20
  end

  context "publish_job_log_message" do
    let(:data) { 'log' }
    subject { job.publish_job_log_message data }

    it { should be_an_instance_of(Vx::Message::JobLog) }
    its(:job_id)   { should eq job.message.job_id }
    its(:build_id) { should eq job.message.build_id }
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
