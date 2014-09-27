require 'vx/common'

module Vx
  module Worker

    RunScript = Struct.new(:app) do

      include Helper::Config
      include Helper::Instrument
      include Common::Helper::UploadShCommand

      def call(env)
        if env.spawner
          code = instrument("run_script", env.job.instrumentation) do
            run_script(env)
          end

          instrument("run_after_script", env.job.instrumentation) do
            run_after_script(env)
          end

          if code == 0
            app.call env
          else
            case read_state(env)
            when "script"
              code
            else
              code * -1
            end
          end
        else
          app.call env
        end
      end

      private

        def run_script(env)
          file = [env.spawner.work_dir, ".ci_build.sh"].join("/")

          script = [upload_sh_command(file, script_content(env))]
          script << "env - USER=$USER HOME=$HOME SHELL=/bin/bash bash -l #{file}"
          script = script.join(" && ")

          env.spawner.spawn script, read_timeout: read_timeout(env), &env.job.method(:add_to_output)
        end

        def run_after_script(env)
          file = [env.spawner.work_dir, ".ci_after_build.sh"].join("/")

          script = [upload_sh_command(file, after_script_content(env))]
          script << "env - USER=$USER HOME=$HOME SHELL=/bin/bash bash -l #{file}"
          script = script.join(" && ")

          env.spawner.spawn script, read_timeout: read_timeout(env), &env.job.method(:add_to_output)
        end

        def script_content(env)
          buf = ["set -e"]
          buf << "echo before_script > #{env.spawner.work_dir}/.ci_state"
          buf << env.job.message.before_script
          buf << "echo script > #{env.spawner.work_dir}/.ci_state"
          buf << env.job.message.script
          buf.join("\n")
        end

        def after_script_content(env)
          buf = ["set -e"]
          buf << env.job.message.after_script
          buf.join("\n")
        end

        def read_state(env)
          buf = ""
          state_file = "#{env.spawner.work_dir}/.ci_state"
          env.spawner.spawn "cat #{state_file}" do |out|
            buf << out
          end
          buf.strip
        end

        def read_timeout(env)
          env.job.read_timeout_value || default_read_timeout
        end

        def default_read_timeout
          10 * 60
        end

    end
  end
end
