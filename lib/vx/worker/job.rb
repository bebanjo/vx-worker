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
          company_id:   message.company_id,
          company_name: message.company_name,
          project_id:   message.project_id,
          project_name: message.project_name,
          build_id:     message.build_id,
          build_number: message.build_number,
          job_id:       message.job_id,
          job_number:   message.job_number,
          job_version:  message.job_version
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
          instrumentation.merge(
            tm: output_counter,
            log: str
          )
        )
        JobLogsConsumer.publish(
          log,
          headers: instrumentation
        )
        log
      end

    end
  end
end
