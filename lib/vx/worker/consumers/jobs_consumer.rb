require 'vx/common/amqp'
require 'vx/message'

module Vx
  module Worker
    class JobsConsumer

      include Vx::Common::AMQP::Consumer

      exchange 'vx.jobs'
      queue    'vx.worker.jobs'
      ack      true

      model Message::PerformJob

      def perform(message)
        Worker.logger.tagged self.class.consumer_id do
          job         = Job.new message
          number      = Thread.current[:consumer_id] || 0
          path_prefix = "/tmp/.test/job.#{number}"
          Worker.perform(job, path_prefix)
          ack!
        end
      end

    end
  end
end
