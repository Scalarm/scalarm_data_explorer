# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

#require File.expand_path('../app/models/load_balancer_registration.rb', __FILE__)

LOCAL_MONGOS_PATH = 'bin/mongos'


namespace :service do
  desc 'Start the service'
  task :start, [:debug] => [:ensure_config, :setup, :environment] do |t, args|
    puts 'puma -C config/puma.rb'
    %x[puma -C config/puma.rb]

    # TODO
    # load_balancer_registration

    # start monitoring only if there is configuration
    # TODO
    # if Rails.application.secrets.monitoring
    #   monitoring_probe('start')
    # else
    #   puts 'Monitoring probe disabled due to lack of configuration'
    # end
  end

  desc 'Stop the service'
  task :stop, [:debug] => [:environment] do |t, args|
    puts 'pumactl -F config/puma.rb -T scalarm stop'
    %x[pumactl -F config/puma.rb -T scalarm stop]

    # TODO
    # if Rails.application.secrets.monitoring
    #   monitoring_probe('stop')
    # else
    #   puts 'Monitoring probe will not be stopped due to lack of configuration'
    # end

    # TODO
    # load_balancer_deregistration
  end

  desc 'Restart the service'
  task restart: [:stop, :start] do
  end

  desc 'Removing unnecessary digests on production'
  task non_digested: :environment do
    Rake::Task['assets:precompile'].execute
    assets = Dir.glob(File.join(Rails.root, 'public/assets/**/*'))
    regex = /(-{1}[a-z0-9]{32}*\.{1}){1}/
    assets.each do |file|
      next if File.directory?(file) || file !~ regex

      source = file.split('/')
      source.push(source.pop.gsub(regex, '.'))

      non_digested = File.join(source)
      FileUtils.cp(file, non_digested)
    end
  end

  desc 'Create default configuration files if these do not exist'
  task :ensure_config do
    copy_example_config_if_not_exists('config/secrets.yml')
    copy_example_config_if_not_exists('config/puma.rb')
  end

  desc 'Downloading and installing dependencies'
  task :setup, [:debug] => [:environment] do
    puts 'Setup started'
    install_r_libraries

    _validate_service
    puts 'Setup finished'
  end

  desc 'Update Monitoring and SimulationManager packages from binary repo'
  task update: ['get:monitoring', 'get:simulation_managers'] do
  end

  desc 'Check dependencies'
  task :validate do
    begin
      _validate_service
    rescue Exception => e
      puts "Error on validation, please read documentation and run service:setup"
      raise
    end
  end

end

# TODO
# namespace :load_balancer do
#   desc 'Registration to load balancer'
#   task :register do
#     load_balancer_registration
#   end
#
#   desc 'Deregistration from load balancer'
#   task :deregister do
#     load_balancer_deregistration
#   end
# end


# ================ UTILS
def start_router(config_service_url)
  bin = mongos_path
  puts "Using: #{bin}"
  puts `#{bin} --version 2>&1`
  router_cmd = "#{mongos_path} --bind_ip localhost --configdb #{config_service_url} --logpath log/db_router.log --fork --logappend"
  puts router_cmd
  puts %x[#{router_cmd}]
end

def stop_router
  proc_name = "#{mongos_path} .*"
  out = %x[ps aux | grep "#{proc_name}"]
  processes_list = out.split("\n").delete_if { |line| line.include? 'grep' }

  processes_list.each do |process_line|
    pid = process_line.split(' ')[1]
    puts "kill -15 #{pid}"
    system("kill -15 #{pid}")
  end
end

def monitoring_probe(action)
  probe_pid_path = File.join(Rails.root, 'tmp', 'scalarm_monitoring_probe.pid')

  case action
    when 'start'
      Process.daemon(true)
      monitoring_job_pid = fork do
        # requiring all class from the model
        Dir[File.join(Rails.root, 'app', 'models', '**/*.rb')].each do |f|
          require f
        end

        probe = MonitoringProbe.new
        probe.start_monitoring

        ExperimentWatcher.watch_experiments
        InfrastructureFacadeFactory.start_all_monitoring_threads.each &:join
      end

      IO.write(probe_pid_path, monitoring_job_pid)

      Process.detach(monitoring_job_pid)
    when
    if File.exist?(probe_pid_path)
      monitoring_job_pid = IO.read(probe_pid_path)
      Process.kill('TERM', monitoring_job_pid.to_i)
    end
  end
end

# TODO
def install_r_libraries
  puts 'Checking R libraries...'
  Rails.configuration.r_interpreter.eval(
      ".libPaths(c(\"#{Dir.pwd}/r_libs\", .libPaths()))
    if(!require(e1071, quietly=TRUE)){
      install.packages(\"e1071\", repos=\"http://cran.rstudio.com/\")
    }")
end

# TODO
def _validate_service
  # %w(R).each do |cmd|
  #   check_for_command(cmd)
  # end
  true
end

def check_for_command_alt(commands)
  any_cmd = commands.any? do |cmd|
    begin
      check_for_command(cmd)
      true
    rescue StandardError
      puts 'Not found. Checking alternatives...'
      false
    end
  end

  raise 'Some dependecies are missing.' unless any_cmd
end

def check_for_command(command)
  print "Checking for #{command}... "
  `which #{command}`
  unless $?.to_i == 0
    raise "No #{command} found in PATH. Please install it."
  end
  puts 'OK'
end

def mongos_path
  `ls #{LOCAL_MONGOS_PATH} >/dev/null 2>&1`
  if $?.to_i == 0
    LOCAL_MONGOS_PATH
  else
    `which mongos > /dev/null 2>&1`
    if $?.to_i == 0
      'mongos'
    else
      nil
    end
  end
end

# # TODO
# def load_balancer_registration
#   unless Rails.application.secrets.include? :load_balancer
#     puts 'There is no configuration for load balancer in secrets.yml - LB registration will be disabled'
#     return
#   end
#   unless Rails.env.test? or Rails.application.secrets.load_balancer["disable_registration"]
#     LoadBalancerRegistration.register(Rails.application.secrets.load_balancer["address"])
#   else
#     puts 'load_balancer.disable_registration option is active'
#   end
# end
#
# def load_balancer_deregistration
#   unless Rails.application.secrets.include? :load_balancer
#     puts 'There is no configuration for load balancer in secrets.yml - LB deregistration will be disabled'
#     return
#   end
#   unless Rails.env.test? or Rails.application.secrets.load_balancer["disable_registration"]
#     LoadBalancerRegistration.deregister(Rails.application.secrets.load_balancer["address"])
#   else
#     puts 'load_balancer.disable_registration option is active'
#   end
# end

def copy_example_config_if_not_exists(base_name, prefix='example')
  config = base_name
  example_config = "#{base_name}.example"

  unless File.exists?(config)
    puts "Copying #{example_config} to #{config}"
    FileUtils.cp(example_config, config)
  end
end

