require 'vx/consumer'
require 'vx/instrumentation'

require 'active_support/notifications'


$stdout.puts ' --> initializing Vx::Consumer'

module Vx
  module Worker
    ConsumerMiddleware = Struct.new(:app) do
      def call(env)
        prop = env[:properties] || {}
        head = prop[:headers] || {}

        Vx::Instrumentation.with("@fields" => head) do
          app.call(env)
        end
      end
    end
  end
end

Vx::Consumer.configure do |c|
  c.content_type = 'application/x-protobuf'
  c.instrumenter = ActiveSupport::Notifications

  c.use :sub, Vx::Worker::ConsumerMiddleware

  c.on_error do |e, env|
    Vx::Instrumentation.handle_exception("worker", e, env)
  end
end
