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
  end
  
  def create_and_seed_repo(project_working_path)
    create_repo
    seed_repo project_working_path
  end

  ## create base gitolite repository for project
  def create_repo
    # update gitolite-admin/conf/gitolite.conf file
    new_conf_entry = "\n\nrepo #{@project_label}\n      RW+ = #{@users}"
    File.open(@@gitolite_conf_file_path, "a") { |f| f.write new_conf_entry}
    
    # push updates to gitolite-admin repo to create new project repo
    gitolite_repo = git_init @@gitolite_admin_path
    gitolite_repo.add('.')
    gitolite_repo.commit("Added repo #{@project_label} with users: #{@users}")
    gitolite_repo.push
    
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

  private
  
  ## Initialise git repository at given path
  def git_init(repo_path)
    git_repo = Git.init repo_path
    git_repo.config('user.name', @@git_user_name)
    git_repo.config('user.email', @@git_user_email)
    return git_repo
  end
  
end