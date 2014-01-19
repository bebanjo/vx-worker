require 'vx/common/amqp'

module Vx
  module Worker
    class JobStatusConsumer

      include Vx::Common::AMQP::Consumer

      exchange 'vx.jobs.status'

    end
  end
end
