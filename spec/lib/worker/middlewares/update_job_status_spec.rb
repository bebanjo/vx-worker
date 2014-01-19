require 'spec_helper'

describe Vx::Worker::UpdateJobStatus do
  let(:exit_code)   { 0 }
  let(:app)         { ->(_) { exit_code } }
  let(:job)         { create :job }
  let(:env)         { OpenStruct.new job: job }
  let(:mid)         { described_class.new app }
  let(:messages)    { Vx::Worker::JobStatusConsumer.messages }

  subject { mid.call env }

  it "should delivery 2 messages" do
    expect {
      subject
    }.to change(messages, :size).by(2)
  end

  { 0 => 3, 1 => 4, -1 => 5 }.each do |code, status|
    context "when exit code is #{code}" do
      let(:exit_code) { code }
      it { should eq code }

      context "messages" do
        before { mid.call env }

        context "first" do
          subject { messages.first }
          it_should_behave_like "UpdateJobStatus message" do
            its(:status) { should eq 2 }
          end
        end

        context "last" do
          subject { messages.last }
          it_should_behave_like "UpdateJobStatus message" do
            its(:status) { should eq status }
          end
        end

      end
    end
  end

  context "when raise exception" do
    let(:app) { ->(_) { raise "Ignore Me" } }
    it { should eq(-1) }

    context "messages" do
      before { mid.call env }

      context "first" do
        subject { messages.first }
        it_should_behave_like "UpdateJobStatus message" do
          its(:status) { should eq 2 }
        end
      end

      context "last" do
        subject { messages.last }
        it_should_behave_like "UpdateJobStatus message" do
          its(:status) { should eq 5 }
        end
      end
    end

    context "Timeout::Error" do
      let(:app) { ->(_) { raise Timeout::Error.new("Timeout Ignore Me") } }

      it { should eq(-1) }
    end
  end

end

