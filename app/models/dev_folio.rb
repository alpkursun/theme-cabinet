class DevFolio
  include Mongoid::Document
  
  # If set to true, this will enable validation of the developer's public key
  # and it will be set up as a gitolite key for the developer; if false, it won't
  DEV_PUB_KEY_ENABLED = false
  
  field :label, type: String
  field :job_id, type: String
  field :dev_id, type: String
  field :dev_public_key_name, type: String
  field :dev_public_key_text, type: String
  field :dev_password, type: String
  
  validates_presence_of   :label
  validates_uniqueness_of :label

  validates_presence_of   :job_id
  validates_presence_of   :dev_id
  validates_presence_of   :dev_password
  validates_presence_of   :dev_public_key_text, on: DEV_PUB_KEY_ENABLED
  
  def dev_public_key=(file_data)
    @file_data = file_data
  end
  
  def dev_public_key
    return self.dev_public_key_name
  end
 
  before_validation :init
  before_save :create_repo
  after_save :stage_wp_site
  before_destroy :delete_repo
  
  # commit and push updates to the dev repo
  def push_repo
    if not @gitman
      self.init
    end
    @gitman.update_repo
  end
  
  protected
  
  def init
    # TODO add public key file content validation here when that feature is phased in
    
    # if a file is uploaded, use its content as the public key text
    if @file_data
      self.dev_public_key_text = @file_data.read
    end
    self.label = "#{self.job_id}#{self.dev_id}"
    @gitman = Gitman.new(self.label, self.dev_id)
  end
  
  def save_public_key 
    self.dev_public_key_name = @gitman.save_public_key self.dev_public_key_text, self.dev_id
  end
  
  def create_repo
    # save the developer's public key if this option is enabled
    if DEV_PUB_KEY_ENABLED
      save_public_key
    end
    # create the repo for the developer
    is_repo_created = @gitman.create_repo
    # if creating the repo succeeded (ie, no duplicates), then seed it
    # get the working directory path for this project's files
    if is_repo_created
      job = JobFolio.where(job_id: self.job_id).first()
      @gitman.seed_repo job.content_path
    end
  end
  
  # Create the wordpress staging site
  def stage_wp_site
    # Note - this assumes that the wordpress files are saved in the repository that
    # the WPDeploy script will look for them in a particular directory
    begin 
      wpd = WpDeploy.new(self.label, self.dev_id, self.dev_password)
      wpd.deploy
    rescue Exception => e
      LOGGER.error "Error occurred staging developer's wordpress site: #{e.message}"
    end
  end
  
  def delete_repo
    if not @gitman
      self.init
    end
    begin 
      @gitman.delete_repo
    rescue Exception => e
      LOGGER.error "Error occurred deleting repository #{self.label} from git (#{e.message}), but deleting dev_folio record anyway ..." 
    end
  end
  
end
