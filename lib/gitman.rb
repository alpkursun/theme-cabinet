class Gitman
  
  @@gitolite_admin_path = APP_CONFIG['gitolite_admin_path']
  @@gitolite_work_dir_path = APP_CONFIG['git_work_dir_path']
  @@gitolite_conf_file_path = File.join(@@gitolite_admin_path, 'conf', 'gitolite.conf')
  @@gitolite_keydir_path = File.join(@@gitolite_admin_path, 'keydir')
  @@git_user_name = APP_CONFIG['git_user_name']
  @@git_user_email = APP_CONFIG['git_user_email']
  @@git_repo_prefix = APP_CONFIG['git_repo_prefix']
  
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
    # clone the empty git repo created for this project
    FileUtils.mkdir_p @project_git_work_path 
    project_repo = Git.clone "#{@@git_repo_prefix}#{@project_label}.git",
                    @project_label, 
                    :path => @@gitolite_work_dir_path
    
    # copy the project files into the git working directory
    FileUtils.cp_r Dir.glob(File.join(project_working_path, '*')), @project_git_work_path
    
    # stage and commit the newly copied files
    project_repo.add('.')
    project_repo.commit("Seeded repo #{@project_label} with project files")
    project_repo.push
  end
  
  # Commit and push developer's changes to repository
  def update_repo
    git_push @project_git_work_path, "Updated repo #{@project_label}"
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