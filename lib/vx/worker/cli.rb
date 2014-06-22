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

          Control.new(workers).watch_async

          run_loop workers
        rescue Exception => e
          Vx::Instrumentation.handle_exception("cli_run.worker.vx", e, {})
        end
      end

      def run_loop(workers)
        workers.map(&:wait_shutdown).map(&:join)
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
            opts.on("-m", "--once-min NUM", 'Minumun worked time') do |v|
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
