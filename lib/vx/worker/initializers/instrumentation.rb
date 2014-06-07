require 'vx/instrumentation'
require 'active_support/notifications'

Vx::Instrumentation.install Vx::Worker.root.join("log/vxworker.log.json")

$stdout.puts ' --> initializing ActiveSupport::Notifications'

ActiveSupport::Notifications.subscribe(/.*/) do |event, started, finished, _, payload|
  ignored = false

  if event == 'process_publishing.consumer.vx'
    ignored = (payload[:consumer] == 'Vx::Worker::JobLogsConsumer')
  end

  unless ignored
    Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
  end
end
