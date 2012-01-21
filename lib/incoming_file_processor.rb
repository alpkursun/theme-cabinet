# This class will be called to process wordpress zip files.

class IncomingFileProcessor
  
  @@unzip_to_path = APP_CONFIG["wordpress_unzip_path"]
  
  # Process a wordpress ZIP file.
  # +file_path+:: absolute path of file to be processed
  def process_file(file_path)
    LOGGER.debug "WordpressPad.process_file was called to process file #{file_path}"
    begin
      # unzip the file
      
      # get job_id from the manifest file
      
      # initialize job_folio
      
    rescue # handle failure to unzip file
       
    end
    
  end
  
end