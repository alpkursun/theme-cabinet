# This class will be called to process wordpress zip files.
# NOTE: This relies on a bash unzip command.

class IncomingFileProcessor
  
  @@unzip_to_path = APP_CONFIG["wordpress_unzip_path"]
  @@ftp_processed_path = APP_CONFIG["ftp_processed_path"]
  @@marketplace_db_conn = APP_CONFIG["marketplace_db_conn"]
  @@marketplace_db_name = APP_CONFIG["marketplace_db_name"]
  
  # Process a wordpress ZIP file. This will:
  # - Unzip the ZIP file contents to the configured working directory
  # - Create a JobFolio for the project, which will create a new 
  #   gitolite repository for the job and commit the extracted files 
  #   to it.
  #
  # +file_path+:: absolute path of file to be processed
  #
  def process_file(file_path)
    LOGGER.debug "Processing file #{file_path}"
    begin
      # get the job id
      job_id = get_job_id(file_path)
      
      # ensure that the job id corresponds to an actual project, otherwise abort processing
      if not check_project_exists(job_id)
        raise "Aborted processing of file due to unmatched project: #{file_path}"
      end
      
      # set the output directory name based on job id
      output_path = File.join @@unzip_to_path, job_id
      
      # remove destination directory if it already exists
      if File.directory? output_path
        FileUtils.remove_entry_secure output_path
      end
      
      # create unzip destination directory (and all required parents if missing)
      FileUtils.mkdir_p output_path
      
      # unzip the file using bash command
      LOGGER.debug "Unzipping file to #{output_path} ... "
      output = %x[ unzip #{file_path} -d #{output_path} ]
      LOGGER.debug output
      
      # create and save job_folio
      JobFolio.save_new_folio(job_id, output_path)
      
      # move the zip file to the 'processed' directory
      # force overwriting of files if they already exist to avoid interactive prompt
      FileUtils.mv file_path, @@ftp_processed_path, :force => true
      
      # update the record for the project to indicate that the content has been received
      update_marketplace_db job_id
      
    rescue Exception => e
      LOGGER.error "An error occurring processing inbound file: #{e.message}"
    end
    
  end
  
  private
  
  def get_job_id(file_path)
    # get the job id based on the zip file name
    return File.basename(file_path, ".zip") # this will return the zip file name without its extension
  end
  
  # Add a flag to the project document in the market place DB to indicate that the files have been uploaded
  def update_marketplace_db(job_id)
    begin
      LOGGER.debug "Updating marketplace project in DB #{@@marketplace_db_name} for plugin_id #{job_id}"
      mongodb_conn = Mongo::Connection.from_uri(@@marketplace_db_conn)
      mongodb_db = mongodb_conn[@@marketplace_db_name]
      mongodb_project_coll = mongodb_db['projects']
      mongodb_project_coll.update({"plugin_id" => job_id}, {"$set" => {"uploaded" => "true"}})
    rescue Exception => e
      LOGGER.error "Error occurred updating marketplace DB #{@@marketplace_db_name} for plugin_id #{job_id}: #{e.message}"
    ensure
      mongodb_conn.close unless mongodb_conn.nil?
    end
  end
  
  # Check that a project exists with plugin_id = job_id. Returns true if yes, false otherwise.
  def check_project_exists(job_id)
    begin
      LOGGER.debug "Updating marketplace project in DB #{@@marketplace_db_name} for plugin_id #{job_id}"
      mongodb_conn = Mongo::Connection.from_uri(@@marketplace_db_conn)
      mongodb_db = mongodb_conn[@@marketplace_db_name]
      mongodb_project_coll = mongodb_db['projects']
      project_record = mongodb_project_coll.find({"plugin_id" => job_id})
      if project_record.count > 0 
        return true
      else
        return false
      end
    rescue Exception => e
      LOGGER.error "Error occurred updating marketplace DB #{@@marketplace_db_name} for plugin_id #{job_id}: #{e.message}"
    ensure
      mongodb_conn.close unless mongodb_conn.nil?
    end
  end
  
end