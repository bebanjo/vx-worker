require 'vx/consumer'

module Vx
  module Worker
    class ControlConsumer
      include Vx::Consumer

      exchange 'vx.cloud.control'

      model Hash
      content_type 'application/json'

    end
  end
end
