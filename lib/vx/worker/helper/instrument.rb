require 'active_support/notifications'

module Vx
  module Worker
    module Helper::Instrument

      def instrument(event, payload, &block)
        ActiveSupport::Notifications.instrument("#{event}.worker.vx", payload, &block)
      end

    end
  end
end
