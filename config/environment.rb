# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path(File.dirname(__FILE__) + "/logger")

# Initialize the rails application
Cabinet::Application.initialize!
