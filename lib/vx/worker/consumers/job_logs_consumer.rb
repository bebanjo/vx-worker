require 'vx/consumer'

module Vx
  module Worker
    class JobLogsConsumer

      include Vx::Consumer

      exchange 'vx.jobs.log'

    end
  end
end
