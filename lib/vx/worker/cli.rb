require 'optparse'
require 'vx/consumer'
require 'vx/instrumentation'

module Vx
  module Worker
    class CLI

      include Helper::Config

      def initialize(opts = {})
        @options = opts
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
        started_at  = Time.now
        last_run_at = Time.now

        loop do
          if workers.any?(&:running?)
            last_run_at = Time.now
          end

          if once_timeout?(last_run_at, started_at)
            $stdout.puts " --> not more jobs, graceful shutdown"
            workers.map(&:graceful_shutdown)
            $stdout.puts " --> shutdown complete"
            break
          else
            sleep 1
          end
        end
      end

      def once_timeout?(last_run_at, started_at)
        shutdown_timeout            = 2 * 60 # 2 minutes
        remainder_must_be_less_then = 55 # minutes
        is_timeout = (last_run_at.to_i + shutdown_timeout) < Time.now.to_i

        if t = @options[:once_min]
          remainder = (started_at.to_i / 60) % 60
          #puts [is_timeout, started_at, remainder, t].inspect
          is_timeout and
            (remainder > t) and
            (remainder < remainder_must_be_less_then)
        else
          is_timeout
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
            opts.on("-m", "--once-min", 'Minumun worked time') do |v|
              @options[:once_min] = v.to_i
            end
          end.parse!

          @options.each_pair do |k,v|
            config.public_send("#{k}=", v)
          end
        end
    end
  end
end
