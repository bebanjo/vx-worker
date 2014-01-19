require File.expand_path '../../lib/vx/worker', __FILE__

Bundler.require(:test)
require 'rspec/autorun'
require 'vx/common/amqp/testing'
require 'vx/message/testing'

Dir[File.expand_path("../..", __FILE__) + "/spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr

  config.before(:each) do
    Vx::Common::AMQP::Testing.clear
    Vx::Worker.reset_config!

    Vx::Worker.configure do |c|
=begin
      c.docker.ssh.port = 2223
      c.docker.ssh.host = 'localhost'
      c.docker.create_options = {
        'PortSpecs' => ['2022:22']
      }
=end
    end
  end
end
