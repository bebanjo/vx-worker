def all_job_log_output
  Vx::Worker::JobLogsConsumer.messages.map{|i| i.log }.join("\n")
end
