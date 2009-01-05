require 'test/vlad_test_case'
require 'vlad'
require 'vlad/git'

class TestVladGit < VladTestCase
  def setup
    super
    @scm = Vlad::Git.new
    set :deploy_to, 'foo'
    set :repository, "git@myhost:/home/john/project1"
  end
  
  def test_should_define_setup_git_task
    Vlad::Git.setup_rake_tasks
    assert_not_nil Rake::Task['vlad:setup:git']
  end
  
  def test_setup_should_clone_the_repository_specified_to_a_default_destination
    cmd = @scm.setup
    assert_equal 'cd foo/scm && git clone git@myhost:/home/john/project1 repo', cmd
  end
  
  def test_checkout_changes_into_the_repo_dir
    cmd = @scm.checkout('master', '.')
    assert_match "cd foo/scm/repo", cmd
  end
  
  def test_checkout_should_checkout_master
    cmd = @scm.checkout('master', '.')
    assert_match "git checkout -f master", cmd  
  end
    
  def test_checkout_should_fetch
    cmd = @scm.checkout('master', '.')
    assert_match "git fetch", cmd
  end
  
  def test_checkout_should_fetch_tags
    cmd = @scm.checkout('master', '.')
    assert_match "git fetch --tags", cmd
  end
  
  def test_checkout_should_checkout_the_specified_revision
    cmd = @scm.checkout('master', '.')
    assert_match "git checkout -f master", cmd
  end
  
  def test_checkout_should_rename_head_to_HEAD
    cmd = @scm.checkout('head', '.')
    assert_match "git checkout -f HEAD", cmd
  end
  
  def test_checkout_should_init_submodules
    cmd = @scm.checkout('master', '.')
    assert_match "git submodule init", cmd
  end
  
  def test_checkout_should_update_submodules
    cmd = @scm.checkout('master', '.')
    assert_match "git submodule update", cmd
  end

  def test_export_creates_the_release_directory
    cmd = @scm.export 'master', 'the/release/path'
    assert_match "mkdir -p the/release/path", cmd
  end

  def test_export_should_copy_over_the_repo
    cmd = @scm.export 'master', 'the/release/path'
    assert_match "cp -r foo/scm/repo/* the/release/path/", cmd
  end
      
  def test_export_removes_all_dot_git_directories
    cmd = @scm.export 'master', 'the/release/path'
    assert_match "cd the/release/path && find . -name '.git' -type d -delete", cmd
  end

end
