# This will initialize the configuration in ../config.yml

APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]

directories_reqd = APP_CONFIG.map{|k, v| /.*path/.match(k); v}

#make the directories if they dont exist
FileUtils.mkdir_p(directories_reqd)

# Start the file listener which will listen for FTP files
FileListener.instance.start_listening