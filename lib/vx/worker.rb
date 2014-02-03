require 'rubygems'
require 'pathname'
require 'thread'

require File.expand_path("../worker/ext/string", __FILE__)
require File.expand_path("../worker/version",    __FILE__)

module Vx
  module Worker

    autoload :JobsConsumer,          File.expand_path("../worker/consumers/jobs_consumer",             __FILE__)
    autoload :JobLogsConsumer,       File.expand_path("../worker/consumers/job_logs_consumer",         __FILE__)
    autoload :JobStatusConsumer,     File.expand_path("../worker/consumers/job_status_consumer",       __FILE__)
    autoload :Configuration,         File.expand_path("../worker/configuration",                       __FILE__)
    autoload :Job,                   File.expand_path("../worker/job",                                 __FILE__)
    autoload :Local,                 File.expand_path("../worker/local",                               __FILE__)
    autoload :Docker,                File.expand_path("../worker/docker",                              __FILE__)
    autoload :CLI,                   File.expand_path("../worker/cli",                                 __FILE__)
    autoload :OutputBuffer,          File.expand_path("../worker/output_buffer",                       __FILE__)

    autoload :LogJob,                File.expand_path("../worker/middlewares/log_job",                 __FILE__)
    autoload :UpdateJobStatus,       File.expand_path("../worker/middlewares/update_job_status",       __FILE__)
    autoload :Timeout,               File.expand_path("../worker/middlewares/timeout",                 __FILE__)
    autoload :StartConnector,        File.expand_path("../worker/middlewares/start_connector",         __FILE__)
    autoload :RunScript,             File.expand_path("../worker/middlewares/run_script",              __FILE__)

    module Helper
      autoload :Config,              File.expand_path("../worker/helper/config",                       __FILE__)
      autoload :Instrument,          File.expand_path("../worker/helper/instrument",                   __FILE__)
    end

    extend self

    @@root   = Pathname.new File.expand_path('../../..', __FILE__)
    @@config_mutex = Mutex.new

    def configure
      yield config
      config
    end

    def config
      @config ||= begin
        @@config_mutex.synchronize do
          Configuration.new
        end
      end
    end

    def root
      @@root
    end

    def perform(job, path_prefix)
      rs = run_class.new(job, path_prefix).perform
      job.release
      rs
    end

    def run_class
      self.const_get(config.run.to_s.camelize)
    end

    def reset_config!
      @config = nil
    end

    def initialize!
      root.join("lib/vx/worker/initializers").children.each do |e|
        require e
      end
    end

  end
end
