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
  
  def init
    # TODO add public key file content validation here
    self.dev_public_key_name = @file_data.original_filename # set filename here to ensure validation
    self.label = self.job_id + "_" + self.dev_id
    @gitman = Gitman.new(self.label, self.dev_id)
  end
  
  def save_public_key 
    self.dev_public_key_name = @gitman.save_public_key @file_data.read, self.dev_id
  end
  
  def create_repo
    # create the repo for the developer
    @gitman.create_repo
    # get the working directory path for this project's files
    job = JobFolio.where(job_id: self.job_id).first()
    @gitman.seed_repo job.content_path
  end
  
  # TODO add code to delete saved public keys when row is deleted from db
  # TODO fix issue with duplicating gitolite.conf entry
  
end
