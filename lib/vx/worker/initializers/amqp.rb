require 'airbrake'
require 'vx/consumer'
require 'active_support/notifications'
require 'vx/instrumentation'

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

  c.use :pub, Vx::Worker::ConsumerMiddleware
  c.use :sub, Vx::Worker::ConsumerMiddleware

  c.on_error do |e, env|
    Vx::Instrumentation.handle_exception("worker", e, env)
    Airbrake.notify(e, env)
  end
end
