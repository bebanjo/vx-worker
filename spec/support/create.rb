require 'yaml'

def create(who, *args)

  options = args.last.is_a?(Hash) ? args.pop : {}

  case who

  when :message
    name  = args.shift
    klass = Vx::Message.const_get name
    klass.test_message options

  when :job
    message = options[:message] || create(:message, 'PerformJob', options)
    Vx::Worker::Job.new message

  end
end
