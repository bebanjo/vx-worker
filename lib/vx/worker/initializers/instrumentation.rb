require 'vx/instrumentation'
require 'active_support/notifications'


Vx::Instrumentation.install Vx::Worker.root.join("log/vxworker.log.json")

$stdout.puts ' --> initializing ActiveSupport::Notifications'

ActiveSupport::Notifications.subscribe(/.*/) do |event, started, finished, _, payload|
  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
