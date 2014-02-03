require 'vx/common'

module Vx
  module Worker

    class Docker

      include Common::Helper::Middlewares

      attr_reader :job

      middlewares do
        use LogJob
        use UpdateJobStatus
        use Timeout
        use StartConnector
        use RunScript
      end

      def initialize(job, _)
        @job = job
      end

      def perform
        env = OpenStruct.new job: job
        run_middlewares(env){ |_| 0 }
      end

    end

  end
end
