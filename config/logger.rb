# Configure logging.
# We use various outputters, so require them, otherwise config chokes
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/fileoutputter'
require 'log4r/outputter/datefileoutputter'
require 'log4r/outputter/emailoutputter'

RAILS_ROOT = Rails.root.to_s
RAILS_ENV  = Rails.env
 
cfg = Log4r::YamlConfigurator
cfg['RAILS_ROOT'] = RAILS_ROOT
cfg['RAILS_ENV'] = RAILS_ENV

# load the YAML file with this
cfg.load_yaml_file("#{RAILS_ROOT}/config/log4r.yml")
RAILS_DEFAULT_LOGGER = Log4r::Logger['default']
RAILS_DEFAULT_LOGGER.level = (RAILS_ENV == 'development' ? Log4r::DEBUG : Log4r::INFO)

if RAILS_ENV == 'test'
  Log4r::Outputter['stderr'].level = Log4r::OFF
  RAILS_DEFAULT_LOGGER.add( Log4r::Outputter['stderr_test'] )
end

if RAILS_ENV == 'production'
  Log4r::Outputter['standardlog'].level = Log4r::OFF
  Log4r::Outputter['stderr'].level = Log4r::OFF
else
  Log4r::Outputter['email'].level = Log4r::OFF
end

