require 'mysql2'

class WpDeploy

	def get_connection( user, password, host = 'localhost')
		Mysql2::Client.new(:host => host, :username => user, :password => password)
	end

	def create_user( conn, user, password )
		conn.query("SELECT 1 FROM mysql.user WHERE user = '#{user}'").each do |res|
  # ugh, user already exists
  #   return false
		end
		conn.query("CREATE USER '#{user}'\@'localhost' IDENTIFIED BY '#{password}'")
	end

	def create_database( conn, db_name )
		conn.query("DROP DATABASE IF EXISTS #{db_name}")
		conn.query("CREATE DATABASE #{db_name}")
	end

	def grant_db_privileges( conn, db_name, user )
		conn.query("GRANT SELECT,INSERT,UPDATE,DELETE,ALTER,CREATE,DROP,INDEX ON #{db_name}.* TO '#{user}'\@'localhost'")
		conn.query("FLUSH PRIVILEGES")
	end

  # load site sql dump
  # note the no space between '-p' and '  #{password} THIS IS INTENTIONAL
	def load_data( db_name, user, password, db_data_file )
  # test file exists
		if File.exist?(db_data_file)
			`mysql -u #{user} -p#{password} #{db_name} < #{db_data_file}`
		else
			puts "File #{db_data_file} doesn't exist"
		end
	end

	def get_old_domain( conn, db_name )
		res = conn.query("SELECT option_value FROM #{db_name}.#{@wp_table_prefix}options WHERE option_name='siteurl'")
		if (res.count != 1)
			return false;
		else
			res.each do |r|
				return r['option_value']
			end
		end
	end

	def migrate_domain( conn, db_name, new_domain )
		old_domain = get_old_domain( conn, db_name )
		
		# replace siteurl and home options
		conn.query("UPDATE #{db_name}.#{@wp_table_prefix}options SET option_value =	replace(option_value, '#{old_domain}', '#{new_domain}') WHERE option_name = 'siteurl' OR option_name = 'home'")

	  # replace urls in posts and pages
	  conn.query("UPDATE #{db_name}.#{@wp_table_prefix}posts SET guid = replace(guid, '#{old_domain}', '#{new_domain}')")

	  # replace backlinks in posts
	  conn.query("UPDATE #{db_name}.#{@wp_table_prefix}posts SET post_content = replace(post_content, '#{old_domain}', '#{new_domain}')")

	end

=begin
	def load_data( conn, db_name, db_data_file )
		sql_data = File.read( db_data_file )
		conn.query("USE   #{db_name}")
		conn.query(sql_data)	
	end
=end

  # returns an 8 character token
	def rand_token
		tok = rand(36**8).to_s(36)
		if (tok.length < 8)
			rand_token
		else
			tok
		end
	end

  # processes the wp-config.php file
	def process_wp_config( db_name, user, password, host = 'localhost' )

  # wp config file
		filename = @wp_config_file 

  # unique keys and salts
		uuid_key = rand_token 
		uuid_salt = rand_token 

  # load wp-config.php
		cfg = File.read(filename) 

  # reset database params
		cfg = cfg.gsub(/define\('DB_NAME',\s*'[^'\r\n]*'\)/, "define('DB_NAME', '#{db_name}')") 
		cfg = cfg.gsub(/define\('DB_USER',\s*'[^'\r\n]*'\)/, "define('DB_USER', '#{user}')") 
		cfg = cfg.gsub(/define\('DB_PASSWORD',\s*'[^'\r\n]*'\)/, "define('DB_PASSWORD', '#{password}')") 
		cfg = cfg.gsub(/define\('DB_HOST',\s*'[^'\r\n]*'\)/, "define('DB_HOST', '#{host}')") 

  # reset all the unique keys and salts
		cfg = cfg.gsub(/define\('AUTH_KEY',\s*'[^'\r\n]*'\)/, "define('AUTH_KEY', '#{uuid_key}')") 
		cfg = cfg.gsub(/define\('SECURE_AUTH_KEY',\s*'[^'\r\n]*'\)/, "define('SECURE_AUTH_KEY', '#{uuid_key}')") 
		cfg = cfg.gsub(/define\('LOGGED_IN_KEY',\s*'[^'\r\n]*'\)/, "define('LOGGED_IN_KEY', '#{uuid_key}')") 
		cfg = cfg.gsub(/define\('NONCE_KEY',\s*'[^'\r\n]*'\)/, "define('NONCE_KEY', '#{uuid_key}')") 

		cfg = cfg.gsub(/define\('AUTH_SALT',\s*'[^'\r\n]*'\)/, "define('AUTH_SALT', '#{uuid_salt}')") 
		cfg = cfg.gsub(/define\('SECURE_AUTH_SALT',\s*'[^'\r\n]*'\)/, "define('SECURE_AUTH_SALT', '#{uuid_salt}')") 
		cfg = cfg.gsub(/define\('LOGGED_IN_SALT',\s*'[^'\r\n]*'\)/, "define('LOGGED_IN_SALT', '#{uuid_salt}')") 
		cfg = cfg.gsub(/define\('NONCE_SALT',\s*'[^'\r\n]*'\)/, "define('NONCE_SALT', '#{uuid_salt}')") 

  # turn debug on
		cfg = cfg.gsub(/define\('WP_DEBUG',.*\)/, "define('WP_DEBUG', true)") 

		puts "after gsub"
		puts cfg

  # overwrite file
		File.open(filename, "w") do |f|
			f.write(cfg)
		end
  # debug
  #	puts text
	end


  # Init
	def initialize( wp_path, wp_user, wp_password )
		
		@db_user = "root"
		@db_password  = "snoopy311dog"

		# pivot staging environment
		@pivot_domain = "http://107.21.227.54:8080/#{wp_path}"
		@fs_path = "/var/www/#{wp_path}"

		# wordpress..
		@wp_db_name = "wp_" + rand_token
		@wp_db_user = rand_token
		@wp_db_password = rand_token
		@wp_admin_user = wp_user
		@wp_admin_password = wp_password
		@wp_db_data_file = File.join(@fs_path, "wp_db_dump.sql")
		@wp_config_file = File.join(@fs_path, "wp-config.php")
		
		# get the value of $table_prefix from wp_config_file
		File.read(@wp_config_file).each_line do |line|
		  if line.start_with?('$table_prefix')
		    @wp_table_prefix = line.split(' ')[2]
		  end
		end
		
		LOGGER.debug "wp_deploy: fs_path = #{@fs_path}"
		LOGGER.debug "wp_deploy: wp_table_prefix = #{@wp_table_prefix}"

	end

	def deploy

		#puts "creating database"
		# get database connection
		conn = get_connection( @db_user, @db_password )

		# create database
		create_database( conn, @wp_db_name )
		LOGGER.debug "wp_deploy: database   #{@wp_db_name} created"

		# create user
		create_user( conn, @wp_db_user, @wp_db_password )
		LOGGER.debug "wp_deploy: user   #{@wp_db_user} added"

		# grant user privileges on database
		grant_db_privileges( conn, @wp_db_name, @wp_db_user )
		LOGGER.debug "wp_deploy: user   #{@wp_db_user} granted privileges on   #{@wp_db_name}"

		# load sql dump from archive
		load_data( @wp_db_name, @db_user, @db_password, @wp_db_data_file )
		LOGGER.debug "wp_deploy: site database dump loaded into   #{@wp_db_name}"

		# migrate domain links
		migrate_domain( conn, @wp_db_name, @pivot_domain ) 
		LOGGER.debug "wp_deploy: domain links migrated to pivot staging domain"

		# close database connection
		conn.close
		LOGGER.debug "wp_deploy: database connection closed"

		# Process the wp-config.php file
		process_wp_config( @wp_db_name, @wp_db_user, @wp_db_password )
		LOGGER.debug "wp_deploy: wp-config.php updated"
	end
end
