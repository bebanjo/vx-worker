require 'vx/common/amqp'

module Vx
  module Worker
    class JobLogsConsumer

      include Vx::Common::AMQP::Consumer

      exchange 'vx.jobs.log'

    end
  end
end
