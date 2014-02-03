require 'active_support/notifications'

module Vx
  module Worker
    module Helper::Instrument

      def instrument(event, payload, &block)
        ActiveSupport::Notifications.instrument("#{event}.worker", payload, &block)
      end

    end
  end
end
