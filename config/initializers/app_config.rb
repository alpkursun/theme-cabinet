# This will initialize the configuration in ../config.yml

APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]

#make the directories if they dont exist
APP_CONFIG.map{|k, v| if /.*path/.match(k); FileUtils.mkdir_p(v); end}

# Start the file listener which will listen for FTP files
FileListener.instance.start_listening

# Register exit handler call to stop the file listener thread
at_exit { FileListener.instance.stop_listening }

class AppConfig
  class << self
    
    def wp_deploy_enabled?
      APP_CONFIG['wp_deploy_enable']
    end
    
  end
end