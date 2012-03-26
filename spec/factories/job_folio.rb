FactoryGirl.define do
  
  factory :job_folio do
    job_id { UUID.new.generate :compact }
    content_path { "/tmp/#{job_id}" }
  end
  
end