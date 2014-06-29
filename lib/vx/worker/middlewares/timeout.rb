require 'timeout'

module Vx
  module Worker

    Timeout = Struct.new(:app) do

      DEFAULT = 60 * 60

      def call(env)
        rs = nil
        ::Timeout.timeout(timeout_value env) do
          rs = app.call env
        end
        rs
      end

      def timeout_value(env)
        env.job.timeout_value || default_timeout
      end

      def default_timeout
        DEFAULT
      end

    end
  end
end
