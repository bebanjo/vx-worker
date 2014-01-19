require 'socket'
require 'pathname'
require 'vx/container_connector'

module Vx
  module Worker

    StartConnector = Struct.new(:app) do

      include Helper::Config
      include Helper::Logger

      def call(env)
        options = config.connector_options
        options.merge! logger: logger
        env.connector = ContainerConnector.lookup(config.run, options)
        env.connector.start do |spawner|
          env.job.add_to_output "using #{Socket.gethostname}##{spawner.id}\n"
          logger.tagged("#{spawner.id}") do
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
end
