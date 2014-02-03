module Vx
  module Worker

    LogJob = Struct.new(:app) do

      include Helper::Instrument

      def call(env)
        instrument("start_processing", env.job.instrumentation)
        app.call env
      end

    end
  end
end
