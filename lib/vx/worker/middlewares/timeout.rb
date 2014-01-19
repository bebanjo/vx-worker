require 'timeout'

module Vx
  module Worker

    Timeout = Struct.new(:app) do

      def call(env)
        rs = nil
        ::Timeout.timeout(_timeout) do
          rs = app.call env
        end
        rs
      end

      def _timeout
        30 * 60
      end

    end
  end
end
