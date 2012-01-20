class DevFolio
  include Mongoid::Document
  
  field :label, type: String
  field :job_id, type: String
  field :dev_id, type: String
  field :dev_public_key_name, type: String
  
  validates_presence_of   :label
  validates_uniqueness_of :label

  validates_presence_of   :job_id
  validates_presence_of   :dev_id
  validates_presence_of   :dev_public_key_name
  
  def dev_public_key=(file_data)
    @file_data = file_data
    #RAILS_DEFAULT_LOGGER.debug "file data is: #{file_data.read}"
  end
  
  def dev_public_key
    return self.dev_public_key_name
  end
 
  before_validation :init
  before_save :save_public_key
  after_save :create_repo
  before_destroy :delete_repo
  
  protected
  
  def init
    # TODO add public key file content validation here
    
    # set filename here to ensure form validation succeeds
    if @file_data
      self.dev_public_key_name = @file_data.original_filename
    end
    self.label = self.job_id + "_" + self.dev_id
    @gitman = Gitman.new(self.label, self.dev_id)
  end
  
  def save_public_key 
    self.dev_public_key_name = @gitman.save_public_key @file_data.read, self.dev_id
  end
  
  def create_repo
    # create the repo for the developer
    if @gitman.create_repo
      # if creating the repo succeeded (ie, no duplicates), then seed it
      # get the working directory path for this project's files
      job = JobFolio.where(job_id: self.job_id).first()
      @gitman.seed_repo job.content_path
    end
  end
  
  def delete_repo
    if not @gitman
      self.init
    end
    @gitman.delete_repo
  end
  
end
