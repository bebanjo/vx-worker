require 'vx/consumer'
require 'vx/lib/message'

module Vx
  module Worker
    class JobsConsumer

      include Vx::Consumer

      exchange 'vx.jobs'
      queue    'vx.worker.jobs'
      ack

      model Message::PerformJob

      def perform(message)
        job = Job.new message
        Worker.perform(job)
        ack
      end

    end
  end
end
