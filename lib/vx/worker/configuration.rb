require 'hashr'

module Vx
  module Worker
    class Configuration < ::Hashr

      extend Hashr::EnvDefaults

      self.env_namespace = 'vx'
      self.raise_missing_keys = true

      define amqp_url:     nil,
             run:          "docker",
             timeout:      30 * 60,

             workers:          1,
             path_prefix:      nil,

             docker: {
               user:       nil,
               password:   nil,
               init:       nil,
               image:      nil,
               remote_dir: nil
             },

             local: {
               remote_dir: nil
             }

      def timeout
        self[:timeout].to_i
      end

      def run
        self[:run].to_sym
      end

      def path_prefix
        self[:path_prefix] || Dir.pwd
      end

      def connector_options
        self[self.run]
      end

      def connector_remote_dir
        connector_options[:remote_dir]
      end

    end
  end
end
