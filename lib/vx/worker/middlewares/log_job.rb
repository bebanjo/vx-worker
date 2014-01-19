module Vx
  module Worker

    LogJob = Struct.new(:app) do

      include Helper::Logger

      def call(env)
        logger.tagged("job #{env.job.message.id}.#{env.job.message.job_id}") do
          logger.info "starting job"
          rs = app.call env
          logger.info "done job"
          rs
        end
      end

    end
  end
end
