require 'vx/message'
require 'vx/common/error_notifier'

module Vx
  module Worker

    UpdateJobStatus = Struct.new(:app) do

      include Helper::Logger

      STARTED  = 2
      FINISHED = 3
      BROKEN   = 4
      FAILED   = 5

      def call(env)

        update_status env.job, STARTED
        rs = -1
        begin
          rs = app.call env
        rescue ::Timeout::Error => e
          env.job.add_to_output("\n\nERROR: #{e.message}\n")
        rescue ::Exception => e
          env.job.add_to_output("\n\nERROR: #{e.inspect}\n")
          logger.error("ERROR: #{e.inspect}\n    BACKTRACE:\n#{e.backtrace.map{|i| "    #{i}" }.join("\n")}")
          Common::ErrorNotifier.notify(e)
        end

        msg = "\nDone. Your build exited with %s.\n"
        env.job.add_to_output(msg % rs.abs)

        case
        when rs == 0
          update_status env.job, FINISHED
        when rs > 0
          update_status env.job, BROKEN
        when rs < 0
          update_status env.job, FAILED
        end

        rs
      end

      private

        def update_status(job, status)
          publish_status create_message(job, status)
        end

        def create_message(job, status)
          tm = Time.now
          Message::JobStatus.new(
            project_id: job.message.project_id,
            build_id:   job.message.id,
            job_id:     job.message.job_id,
            status:     status,
            tm:         tm.to_i,
          )
        end

        def publish_status(message)
          logger.info "delivered job status #{message.inspect}"
          JobStatusConsumer.publish(
            message,
            headers: {
              build_id:   message.build_id,
              job_id:     message.job_id
            }
          )
        end

    end
  end
end
