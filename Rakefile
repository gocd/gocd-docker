require 'json'

def verify_version(version, task)
  unless version
    puts "Please specify a version for building the docker image"
    puts "e.g. \n GO_VERSION=16.x.x-xxxx rake #{task}"
    puts "or"
    puts "If you want to push the built image to a repository"
    puts "e.g. \n GO_VERSION=16.x.x-xxxx REPOSITORY=repository_name rake #{task}"
    exit(1)
  end
end

def container_name(repository, type)
  return repository ? "#{repository}/#{type}" : type 
end

def docker_build (repository, task, version)
  verify_version(version, task)

  type = "gocd-#{task}"
  container = container_name(repository, type)

  sh("docker build --build-arg GO_VERSION='#{version}' -f Dockerfile.#{type} -t #{container} .")

  if repository
    sh("docker push #{container}")
    sh("docker tag #{container} #{container}:#{version}")
    sh("docker push #{container}:#{version}")
  end
end

desc "Build and push the base gocd image"
task :base do |t, args|
  container = container_name(ENV['REPOSITORY'], "gocd-base")
  sh("docker build -f Dockerfile.gocd-base -t #{container} .")
  
  if ENV['REPOSITORY']
    sh("docker push #{container}")
  end
end

desc "Build and push a specific version of GoCD agent docker container"
task :agent do |t, args|
  docker_build(ENV['REPOSITORY'], t, ENV['GO_VERSION'])
end

desc "Build and push a specific version of GoCD server docker container"
task :server do |t, args|
  docker_build(ENV['REPOSITORY'], t, ENV['GO_VERSION'])
end

desc "Build and push a specific version of GoCD development container with server and agent"
task :dev do |t, args|
  docker_build(ENV['REPOSITORY'], t, ENV['GO_VERSION'])
end

