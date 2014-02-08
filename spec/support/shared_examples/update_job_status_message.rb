shared_examples "UpdateJobStatus message" do
  its(:project_id) { should eq job.message.project_id }
  its(:build_id)   { should eq job.message.build_id }
  its(:job_id)     { should eq job.message.job_id }
  its(:tm)         { should be }
end
