require 'vx/message'
require 'vx/common'

module Vx
  module Worker
    class Job

      attr_reader :output, :message, :output_counter

      def initialize(perform_job_message)
        @output_counter = 0
        @message        = perform_job_message
        @output         = Common::OutputBuffer.new(&method(:publish_job_log_message))
      end

      def add_to_output(str)
        output << str
      end

      def instrumentation
        {
          job_id:   message.job_id,
          build_id: message.id
        }
      end

      def add_command_to_output(cmd)
        add_to_output "$ #{cmd}\n"
      end

      def add_trace_to_output(log)
        add_to_output log.split(/\n/).map{|i| " ===> #{i}\n" }.join
      end

      def release
        output.close
      end

      def publish_job_log_message(str)
        @output_counter += 1
        log = Message::JobLog.new(
          build_id: message.id,
          job_id:   message.job_id,
          tm:       output_counter,
          log:      str
        )
        JobLogsConsumer.publish(
          log,
          headers: {
            build_id: log.build_id,
            job_id:   log.job_id
          }
        )
        log
      end

    end
  end
end
