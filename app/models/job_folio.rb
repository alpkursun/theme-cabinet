class JobFolio
  include Mongoid::Document
  
  field :label, type: String
  field :job_id, type: String
  field :content_path, type: String
  
  validates_presence_of   :label
  validates_uniqueness_of :label

  validates_presence_of   :content_path
  validates_format_of     :content_path, with: /(\/\w*)+/ # validate path

  # call set_path after initializing
  after_initialize  :init
  
  # call grab_page before saving record
  before_save :create_repo

  protected
  
  def init
    
  end
  
  def create_repo
    @repo_url = @@git_repo_base + "/" + self.label
     
  end
  
end
