class JobFolio
  include Mongoid::Document
  
  field :label, type: String
  field :job_id, type: String
  field :content_path, type: String
  
  validates_presence_of   :label
  validates_uniqueness_of :label

  validates_presence_of   :content_path
  validates_format_of     :content_path, with: /(\/\w*)+/ # validate path

  before_validation :init
  
  # call grab_page before saving record
  before_save :create_repo

  protected
  
  def init
    self.label = self.job_id
    @gitman = Gitman.new(self.label, '')
  end
  
  def create_repo
    @gitman.create_and_seed_repo self.content_path
  end
  
end
