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

  def self.save_new_folio(job_id, content_path)
    begin
      job_folio = self.new
      job_folio.job_id = job_id
      job_folio.content_path = content_path
      if job_folio.valid?
        job_folio.save
      end
    rescue Exception => e
      LOGGER.error "Error occurred saving job folio: #{e.message}"
    else
      LOGGER.debug "Successfully saved job folio!"
    end
  end
  
  protected
  
  def init
    self.label = self.job_id
    @gitman = Gitman.new(self.label, '')
  end
  
  def create_repo
    @gitman.create_and_seed_repo self.content_path
  end
  
end
