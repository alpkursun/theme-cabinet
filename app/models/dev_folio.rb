class DevFolio
  include Mongoid::Document
  
  field :label, type: String
  field :job_id, type: String
  field :dev_id, type: String
  field :dev_public_key_name, type: String
  
  #validates_presence_of   :label
  #validates_uniqueness_of :label

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
 
  before_validation :set_derived_fields
  before_save :save_public_key
  after_save :create_repo
  
  def set_derived_fields
    # TODO add public key file content validation here
    self.dev_public_key_name = @file_data.original_filename # set filename here to ensure validation
    self.label = self.job_id + "_" + self.dev_id
  end
  
  def save_public_key 
    pub_key_save_path = File.join(APP_CONFIG['gitolite_keydir_path'], "#{self.dev_id}.pub")
    File.open(pub_key_save_path, "wb") { |f| f.write @file_data.read}
    self.dev_public_key_name = pub_key_save_path
  end
  
  def create_repo
    # update gitolite-admin/conf/gitolite.conf file
    gitolite_conf_file_path = APP_CONFIG['gitolite_conf_file_path']
    new_conf_entry = "\nrepo #{self.label}\n      RW+ = @admins #{self.dev_id}"
    File.open(gitolite_conf_file_path, "a") { |f| f.write new_conf_entry}
    
    # push updates to gitolite-admin repo
    gitolite_working_path = APP_CONFIG['gitolite_working_path']
    gitolite_repo = Git.init gitolite_working_path
    gitolite_repo.config('user.name', 'admin')
    gitolite_repo.config('user.email', 'git.admin@themepivot.com')
    gitolite_repo.add('.')
    gitolite_repo.commit("Added repo #{self.label} for #{self.dev_id}")
    gitolite_repo.push
    
    # clone job repo for developer
    job_repo_url = File.join(APP_CONFIG['gitolite_url_prefix'], "#{self.job_id}.git")
  end
  
  # TODO add code to delete saved public keys when row is deleted from db
  # TODO fix issue with duplicating gitolite.conf entry
  
end
