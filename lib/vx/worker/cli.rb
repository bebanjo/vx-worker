require 'optparse'
require 'vx/common/amqp_setup'
require 'vx/common'

module Vx
  module Worker
    class CLI

      include Helper::Config
      include Helper::Logger
      include Common::EnvFile

      def initialize
        @options = {}
        parse!
        Worker.initialize!
      end

      def run
        trap('INT') {
          Thread.new do
            Vx::Common::AMQP.shutdown
          end.join
        }

        Vx::Common::AMQP::Supervisor::Threaded.build(
          Vx::Worker::JobsConsumer => config.workers,
        ).run
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
