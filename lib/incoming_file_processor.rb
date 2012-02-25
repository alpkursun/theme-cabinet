# This class will be called to process wordpress zip files.
# NOTE: This relies on a bash unzip command.

class IncomingFileProcessor
  
  @@unzip_to_path = APP_CONFIG["wordpress_unzip_path"]
  @@ftp_processed_path = APP_CONFIG["ftp_processed_path"]
  
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
      
      # set the output directory name based on job id
      output_path = File.join @@unzip_to_path, job_id
      
      # create unzip destination directory
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
      
    rescue 
      LOGGER.debug "An error occurring processing inbound file: #{$!}"
    end
    
  end
  
  private
  
  def get_job_id(file_path)
    # get the job id based on the zip file name
    return File.basename(file_path, ".zip") # this will return the zip file name without its extension
  end
  
end

=begin      
      LOGGER.debug "Listing zip file contents ... "
      Archive.read_open_filename(file_path) do |ar|
        while entry = ar.next_header
          
          rel_path = entry.pathname
          data = ar.read_data
      
          #data = ""
          #ar.read_data(1024) do |x|
          #  data << x
          #end
      
          #LOGGER.debug "#{rel_path} (size=#{data.size})"
          #if data.size > 0
          #  LOGGER.debug "  content=[#{data}]"
          #end
        end
      end
=end      
