require 'optparse'
require 'vx/common'
require 'vx/consumer'

module Vx
  module Worker
    class CLI

      include Helper::Config
      include Common::EnvFile

      def initialize
        @options = {}
        parse!
        Worker.initialize!
      end

      def run
        trap('INT') {
          Thread.new do
            Vx::Consumer.shutdown
          end.join
        }

        workers = []
        config.workers.times do |n|
          workers << Vx::Worker::JobsConsumer.subscribe
        end
        workers.map(&:wait)
      end

      private

        def parse!
          OptionParser.new do |opts|
            opts.banner = "Usage: vx-worker [options]"
            opts.on("-w", "--workers NUM", "Number of workers, default 1") do |v|
              @options[:workers] = v.to_i
            end
            opts.on("-p", "--path PATH", "Working directory, default current directory") do |v|
              @options[:path_prefix] = v.to_s
            end
            opts.on("-c", "--config FILE", "Path to configuration file, default /etc/vexor/ci") do |v|
              @options[:config] = v
            end
          end.parse!

          read_env_file @options.delete(:config)

          @options.each_pair do |k,v|
            config.public_send("#{k}=", v)
          end
        end
    end
  end
end
