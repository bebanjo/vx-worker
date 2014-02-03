module Vx
  module Worker

    LogJob = Struct.new(:app) do

      include Helper::Instrument

      def call(env)
        instrument("starting_job", env.job.instrumentation)
        app.call env
      end

    end
  end
end
