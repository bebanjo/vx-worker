require 'airbrake'
require 'vx/common/amqp'
require 'active_support/notifications'

module Vx
  module Worker
    module AMQP
      Middleware = Struct.new(:app) do
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
end

Vx::Common::AMQP.configure do |c|
  c.content_type = 'application/x-protobuf'
  c.instrumenter = ActiveSupport::Notifications
  c.on_error     = ->(e, env) {
    Vx::Instrumentation.handle_exception("worker", e, env)
    Airbrake.notify(e, env)
  }
  c.use :pub, Vx::Worker::AMQP::Middleware
  c.use :sub, Vx::Worker::AMQP::Middleware
end
