require 'socket'
require 'pathname'
require 'vx/container_connector'

module Vx
  module Worker

    StartConnector = Struct.new(:app) do

      include Helper::Config
      include Helper::Instrument

      def call(env)
        options = config.connector_options
        if image = env.job.message.image
          options.merge!(image: image)
        end
        env.connector = ContainerConnector.lookup(config.run, options)

        instrument("starting_container", env.job.instrumentation)

        env.connector.start do |spawner|
          env.job.add_to_output "Using #{Socket.gethostname}/#{spawner.id}\n"

          instrument("container_started", env.job.instrumentation.merge(container: spawner.id))

          begin
            env.spawner = spawner
            app.call env
          ensure
            env.spawner = spawner
          end
        end
      end

    end
  end
end
