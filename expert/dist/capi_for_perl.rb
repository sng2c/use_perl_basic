
namespace :deploy do

  desc "Install Project Dependencies"
  task :check, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/local"
    run "mkdir -p #{shared_path}/log/worker_log"
    run "rm -f #{current_path}/workspace/log ; ln -s #{shared_path}/log #{current_path}/workspace/log"
    run "rm -f #{current_path}/workspace/local ; ln -s #{shared_path}/local #{current_path}/workspace/local"
    run "cd #{current_path}/workspace && carton install --cached --deployment", :pty=>false
  end

  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}/workspace && sh #{start_script}", :pty=>false
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}/workspace && sh #{stop_script}", :pty=>false
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.stop
    deploy.start
  end

  before "deploy:start" do
    deploy.check
  end

  before "deploy:stop" do
    deploy.check
  end

  after "deploy:symlink" do
    run "rm -f #{current_path}/workspace/local ; ln -s #{shared_path}/local #{current_path}/workspace/local"
  end

end
