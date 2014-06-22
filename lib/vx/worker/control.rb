require 'thread'
require 'socket'

module Vx
  module Worker
    class Control

      TIMEOUT = 3 # in seconds

      include Helper::Instrument

      class << self
        def hostname
          @hostname ||= Socket.gethostname
        end
      end

      attr_reader :started_at, :workers, :last_run_at, :timeout, :hostname

      def initialize(workers, options = {})
        @started_at  = Time.now
        @last_run_at = Time.now
        @workers     = workers
        @timeout     = options[:timeout] || ENV['VX_WORKER_TIMEOUT'].to_i
        @hostname    = self.class.hostname
      end

      def watch_async
        Thread.new do
          Thread.current.abort_on_exception = true
          watch
        end
      end

      def watch
        return if timeout == 0

        $stdout.puts " --> control using timeout: #{timeout.inspect}"

        loop do
          if workers.any?(&:running?)
            @last_run_at = Time.now
          end

          if timeout?
            $stdout.puts " --> not more jobs, graceful shutdown"
            instrument("shutdown.control", timeout: timeout) do
              workers.map(&:graceful_shutdown)
            end
            instrument("notify.control", hostname: hostname) do
              notify_shutdown
            end
            $stdout.puts " --> shutdown complete"
            break
          else
            sleep 10
          end
        end
      end

      def notify_shutdown
        ControlConsumer.publish event: "shutdown", hostname: hostname
      end

      def timeout?
        (last_run_at.to_i + timeout) < Time.now.to_i
      end

    end
  end
end
