def last_job_log_message
  Vx::Worker::JobLogsConsumer.messages.last
end
