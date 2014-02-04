require 'vx/consumer'

module Vx
  module Worker
    class JobStatusConsumer

      include Vx::Consumer

      exchange 'vx.jobs.status'

    end
  end
end
