class Vlad::Git

  set :source, Vlad::Git.new
  set :git_cmd, "git"

  ## 
  # Sets up a repository on the remote server to fetch changes to and
  # to deploy new releases from
  
  def setup
    ["cd #{scm_path}",
     "#{git_cmd} clone #{repository} repo"].join(" && ")
  end
  
  ##
  # Returns the command that will check out +revision+ from the
  # repository. +revision+ can be any SHA1 or equivalent 
  # (e.g. branch, tag, etc...)

  def checkout(revision, whatever)
    revision = 'HEAD' if revision =~ /head/i
    
    ["cd #{scm_path}/repo",
     "#{git_cmd} fetch",
     "#{git_cmd} fetch --tags",
     "#{git_cmd} checkout -f #{revision}",
     "#{git_cmd} submodule init",
     "#{git_cmd} submodule update"
    ].join(" && ")
  end

  ##
  # Returns the command that will export +revision+ from the repository into
  # the directory +destination+.

  def export(revision, destination)
    revision = 'HEAD' if revision == "."

    ["mkdir -p #{destination}",
     "cd #{scm_path}/repo && find . | grep -v '/.git' | cpio -p --make-directories #{destination}"
    ].join(" && ")
  end
  
  def self.setup_rake_tasks
    desc "Sets up a Git clone to deploy from on the remote host"
    remote_task 'vlad:setup:git', :roles => :app do
      run source.setup
    end
    
    task('vlad:setup') { Rake::Task['vlad:setup:git'].invoke }
  end
  
  setup_rake_tasks
end