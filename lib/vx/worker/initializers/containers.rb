require 'vx/container_connector'
require 'vx/instrumentation'
require 'active_support/notifications'

$stdout.puts ' --> initializing Vx::ContainerConnector'

Vx::ContainerConnector.instrumenter = ActiveSupport::Notifications
