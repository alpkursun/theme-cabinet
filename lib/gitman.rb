class Gitman
  
  @@gitolite_admin_path = APP_CONFIG['gitolite_admin_path']
  @@gitolite_work_dir_path = APP_CONFIG['git_work_dir_path'] # this is the wordpress staging area
  @@gitolite_conf_file_path = File.join(@@gitolite_admin_path, 'conf', 'gitolite.conf')
  @@gitolite_keydir_path = File.join(@@gitolite_admin_path, 'keydir')
  @@git_user_name = APP_CONFIG['git_user_name']
  @@git_user_email = APP_CONFIG['git_user_email']
  @@git_repo_prefix = APP_CONFIG['git_repo_prefix']
  @@completed_proj_dir = APP_CONFIG['completed_project_dir']
  
  def initialize(project_label, users) 
    @project_label = project_label
    @users = "@admins #{users}"
    @project_git_work_path = File.join @@gitolite_work_dir_path, @project_label
    @gitolite_conf_entry = "\n\nrepo #{@project_label}\n      RW+ = #{@users}" 
  end
  
  def create_and_seed_repo(project_working_path)
    if create_repo
      seed_repo project_working_path
    end
  end

  ## create base gitolite repository for project
  def create_repo
    # update gitolite-admin/conf/gitolite.conf file ...
    # but only if there is NOT already an entry for this repo 
    # ... to avoid duplicating the entry
    conf_entry = File.read(@@gitolite_conf_file_path).slice(@gitolite_conf_entry)
    if (conf_entry == nil)
      File.open(@@gitolite_conf_file_path, "a") { |f| f.write @gitolite_conf_entry}
      # push updates to gitolite-admin repo to create new project repo
      git_push @@gitolite_admin_path, "Added repo #{@project_label} with users: #{@users}"
      return true
    else
      return false
    end
    
  end
  
  ## Seed gitolite repository with project files 
  def seed_repo(project_working_path)
    begin
      # clone the empty git repo created for this project
      FileUtils.mkdir_p @project_git_work_path 
      project_repo = Git.clone "#{@@git_repo_prefix}#{@project_label}.git",
                      @project_label, 
                      :path => @@gitolite_work_dir_path
      
      LOGGER.debug "Copying project files for repo #{@project_label}"
      # copy the project files into the git working directory
      FileUtils.cp_r Dir.glob(File.join(project_working_path, '*')), @project_git_work_path
      LOGGER.debug "Copied project files successfully for repo #{@project_label}"
      
      # stage and commit the newly copied files
      LOGGER.debug "Adding files to repo #{@project_label}"
      project_repo.add('.')
      LOGGER.debug "Committing repo #{@project_label}"
      project_repo.commit("Seeded repo #{@project_label} with project files")
      LOGGER.debug "Pushing repo #{@project_label}"
      project_repo.push
    rescue
      LOGGER.error "Error occurred seeding repo #{@project_label} with project files"
    end
  end
  
  # Commit and push developer's changes to repository
  def update_repo
    git_push @project_git_work_path, "Updated repo #{@project_label}"
    return true
  end
  
  # Zip up the head revision in the repository and copy it to the gitolite_work_dir_path,
  def export_repo
    tag_string = "accepted"
    target_zip_file = "#{File.join(@@completed_proj_dir, @project_label)}.zip"
    # Tag and export the repo head revision contents to project_label + '_accepted'
    begin
      git_repo = git_init @project_git_work_path
      git_repo.add_tag(tag_string)
      git_repo.archive(tag_string, target_zip_file) # defaults to format of 'zip' if not specified in options
      
      # remove unnecessary files from the zip to leave only 
      # the wp-content/themes and wp-content/plugins subdirectories and their contents
      LOGGER.debug "Removing unnecessary files from project zip #{target_zip_file}"
      output = %x[ zip -d #{target_zip_file} -x #{@project_label}/wp-content/plugins/\* #{@project_label}/wp-content/themes/\* ]
      LOGGER.debug output
      
    rescue Exception => e
      LOGGER.error "Error occurred exporting repo #{@project_label}: #{e.message}"
      return false
    end
    LOGGER.debug "Exported repo #{@project_label} to #{target_zip_file}"
    return true
  end

  # Save the public key and return the save path
  # This will check if the file already exists, and if so, will not write to it 
  def save_public_key(pub_key_file_data, dev_id) 
    pub_key_save_path = File.join(@@gitolite_keydir_path, "#{dev_id}.pub")
    if !File.exists?(pub_key_save_path)
      File.open(pub_key_save_path, "wb") { |f| f.write pub_key_file_data}
    else
      LOGGER.debug "Public key file already exists at #{pub_key_save_path}; this will not be overwritten"
    end
    return pub_key_save_path
  end
  
  def delete_repo
    # note - do not delete the dev's public key as they may be working on multiple projects
    # delete the conf file entry for this repo from the gitolite.conf file
    conf = File.read(@@gitolite_conf_file_path)
    conf.slice!(@gitolite_conf_entry)
    File.open(@@gitolite_conf_file_path, "w") { |f| f.write conf }
    
    # commit the update to the gitolite-admin repo
    git_push @@gitolite_admin_path, "Deleted config entry for repo #{@project_label}"
  end
  
  private
  
  ## Initialise git repository at given path
  def git_init(repo_path)
    git_repo = Git.init repo_path
    git_repo.config('user.name', @@git_user_name)
    git_repo.config('user.email', @@git_user_email)
    return git_repo
  end
  
  def git_push(repo_path, log_message)
    gitolite_repo = git_init repo_path
    gitolite_repo.add('.')
    gitolite_repo.commit(log_message)
    gitolite_repo.push
  end
  
end
