# This will initialize the configuration in ../config.yml

APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]

# Start the file listener which will listen for FTP files
FileListener.instance.start_listening