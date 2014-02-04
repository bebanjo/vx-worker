require 'optparse'
require 'vx/common'
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

        begin
          workers = []
          config.workers.to_i.times do |n|
            $stdout.puts " --> boot Vx::Worker::JobsConsumer #{n}"
            workers << Vx::Worker::JobsConsumer.subscribe
          end
          workers.map(&:wait)
        rescue Exception => e
          Vx::Instrumentation.handle_exception("cli_run.worker.vx", e, {})
        end
      end

      private

        def parse!
          OptionParser.new do |opts|
            opts.banner = "Usage: vx-worker [options]"
            opts.on("-w", "--workers NUM", "Number of workers, default 1") do |v|
              @options[:workers] = v.to_i
            end
          end.parse!

          @options.each_pair do |k,v|
            config.public_send("#{k}=", v)
          end
        end
    end
  end
end
