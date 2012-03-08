# This singleton class will monitor the FTP landing directory for zipped 
# wordpress files and kick off their processing as they arrive.

class FileListener
  
  @@ftp_landing_path = APP_CONFIG["ftp_landing_path"]
  @@instance = self.new
  private_class_method :new
  
  # Return instance of FsListener singleton
  def self.instance
    return @@instance
  end
  
  # Start listening to the FTP landing directory.
  def start_listening(*args)
    
    @listen_dir = args.size == 1 ? args[0] : @@ftp_landing_path
    
    @file_listener = fork do
      
      Signal.trap("HUP") do 
        LOGGER.debug "Received HUP signal ... terminating"
        exit
      end
      
      #RAILS_DEFAULT_LOGGER.debug "Listening to #{@listen_dir}"
      FSSM.monitor(@listen_dir, '**/*', :directories => false) do
        create do |basedir, filename, type|
          # log the fact that we've detected a new file
          LOGGER.debug "Detected new #{type == :directory ? 'directory' : 'file'} #{filename} in #{basedir}"
          # kick off the processing of the file
          ifp = fork do 
            IncomingFileProcessor.new.process_file File.join(basedir, filename)
          end
          Process.detach(ifp)
        end
      end
      
    end # end fork
        
    Process.detach(@file_listener)
    
  end
  
  # Stop listening to the FTP landing directory.
  def stop_listening
    if @file_listener
      Process.kill("HUP", @file_listener)
    end
  end
  
end
