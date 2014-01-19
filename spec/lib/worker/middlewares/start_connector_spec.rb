require 'spec_helper'

describe Vx::Worker::StartConnector do
  let(:exit_code)   { 0 }
  let(:app)         { ->(_) { exit_code } }
  let(:job)         { create :job }
  let(:env)         { OpenStruct.new job: job }
  let(:mid)         { described_class.new app }

  subject { mid.call env }

  context "local connector" do
    before do
      Vx::Worker.config.run = "local"
    end

    it "should successfully start" do
      expect(subject).to eq 0
      expect(env.connector).to be
    end
  end

  context "docker connector", docker: true do
    before do
      Vx::Worker.config.run = "docker"
    end

    it "should successfully start" do
      expect(subject).to eq 0
      expect(env.connector).to be
    end
  end
end

