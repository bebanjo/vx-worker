shared_examples "UpdateJobStatus message" do
  its(:build_id) { should eq job.message.id }
  its(:job_id)   { should eq job.message.job_id }
  its(:matrix)   { should eq job.message.matrix_keys }
  its(:tm)       { should be }
end
