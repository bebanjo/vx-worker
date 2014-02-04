require 'vx/consumer'
require 'vx/message'

module Vx
  module Worker
    class JobsConsumer

      include Vx::Consumer

      exchange 'vx.jobs'
      queue    'vx.worker.jobs'
      ack

      model Message::PerformJob

      def perform(message)
        job         = Job.new message
        number      = Thread.current[:consumer_id] || 0
        path_prefix = "/tmp/.worker/job.#{number}"
        Worker.perform(job, path_prefix)
        ack!
      end

    end
  end
end
