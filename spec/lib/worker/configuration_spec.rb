require 'spec_helper'

describe Vx::Worker::Configuration do
  let(:config) { Vx::Worker.config }
  subject { config }

  its(:run)                  { should eq :docker }
  its(:docker)               { should be }
  its(:timeout)              { should eq 1800 }
  its(:amqp_url)             { should be_nil }
  its(:connector_options)    { should eq config.docker }
  its(:connector_remote_dir) { should eq config.docker.remote_dir }

  context "docker" do
    subject { config.docker }

    its(:user)       { should be_nil }
    its(:password)   { should be_nil }
    its(:init)       { should be_nil }
    its(:image)      { should be_nil }
    its(:remote_dir) { should be_nil }
  end

  context "local" do
    subject { config.local }

    its(:remote_dir){ should be_nil }
  end

  context ".configure" do
    subject {
      Vx::Worker.configure do |c|
        c.run = "local"
        c.docker.image = 'image'
      end
    }
    its(:run)           { should eq :local  }
    its("docker.image") { should eq 'image' }
  end
end
