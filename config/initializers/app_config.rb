# This will initialize the configuration in ../config.yml

APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
