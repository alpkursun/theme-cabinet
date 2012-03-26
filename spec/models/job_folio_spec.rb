require 'spec_helper'

describe JobFolio do
  
  before(:each) do
    
    @attr = FactoryGirl.attributes_for(:job_folio)
    puts "@attr = " + @attr.to_s
    job_id = @attr[:job_id]
    content_path = @attr[:content_path]
    
    # if content_path does not exist, create it and add a few dummy files
    if !File.directory?(content_path)
      FileUtils.mkdir_p content_path
      dummy_file1 = File.join(content_path, "dummy1")
      %x[ echo 'dummy file 1' > #{dummy_file1} ]
      dummy_file2 = File.join(content_path, "dummy2")
      %x[ echo 'dummy file 2' > #{dummy_file2} ]
    end
    
  end
  
  after(:each) do
    # Note: deleting the gitolite repository record so that tests are repeatable
    # will not work, as the repo must also be deleted on the server - using UUIDs instead!
    
    # delete the directory & files created for this test
    content_path = @attr[:content_path]
    if File.directory?(content_path)
      puts "cleanup: deleting directory #{content_path}"
      FileUtils.rm_r content_path
    end
    
  end
  
  it "should create a new instance given valid attributes" do
    JobFolio.create! @attr
  end
  
  describe "class methods" do
    it "should create a new instance given valid attributes" do
      job_id = @attr[:job_id]
      expect { JobFolio.save_new_folio job_id, @attr[:content_path] }.should_not raise_error
      job_folio = JobFolio.where(job_id: job_id).first()
      job_folio.job_id.should eq(job_id)
    end
  
    it "should raise exception given invalid attributes" do
      expect { JobFolio.save_new_folio '', '' }.should raise_error
    end
  end
end