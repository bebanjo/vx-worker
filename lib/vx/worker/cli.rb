require 'optparse'
require 'vx/consumer'
require 'vx/instrumentation'

module Vx
  module Worker
    class CLI

      include Helper::Config

      def initialize
        @options = {}
        parse!
        Worker.initialize!
      end

      def run

        trap('INT') {
          $stdout.puts " --> got INT, doing shutdown"
          Thread.new do
            Vx::Consumer.shutdown
          end.join
        }

        trap('TERM') {
          $stdout.puts " --> got TERM, doing shutdown"
          Thread.new do
            Vx::Consumer.shutdown
          end.join
        }

        workers = []
        begin
          config.workers.to_i.times do |n|
            $stdout.puts " --> boot Vx::Worker::JobsConsumer #{n}"
            workers << Vx::Worker::JobsConsumer.subscribe
          end
          if @options[:once]
            $stdout.puts " --> run once, wait jobs 5 minutes and shutdown"
            run_once workers
          else
            run_loop workers
          end
        rescue Exception => e
          Vx::Instrumentation.handle_exception("cli_run.worker.vx", e, {})
        end
      end

      def run_loop(workers)
        workers.map(&:wait_shutdown).map(&:join)
      end

      def run_once(workers)
        shutdown_timeout = 5 * 60 # 5 minutes
        last_run_at = Time.now

        loop do
          if workers.any?(&:running?)
            last_run_at = Time.now
          end

          if (last_run_at.to_i + shutdown_timeout) < Time.now.to_i
            $stdout.puts " --> not more jobs, graceful shutdown"
            workers.map(&:graceful_shutdown)
            $stdout.puts " --> shutdown complete"
            break
          else
            sleep 1
          end
        end
      end

      private

        def parse!
          OptionParser.new do |opts|
            opts.banner = "Usage: vx-worker [options]"
            opts.on("-w", "--workers NUM", "Number of workers, default 1") do |v|
              @options[:workers] = v.to_i
            end
            opts.on("-o", "--once", "Run once") do |o|
              @options[:once] = true
            end
          end.parse!

          @options.each_pair do |k,v|
            config.public_send("#{k}=", v)
          end
        end
    end
  end
end
