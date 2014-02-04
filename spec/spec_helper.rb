Bundler.require(:test)

require File.expand_path '../../lib/vx/worker', __FILE__

require 'rspec/autorun'
require 'vx/consumer/testing'
require 'vx/message/testing'

Dir[File.expand_path("../..", __FILE__) + "/spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr

  config.before(:each) do
    Vx::Consumer::Testing.clear
    Vx::Worker.reset_config!
    Vx::Worker.config.run = "docker"

    Vx::Worker.initialize!
  end
end
