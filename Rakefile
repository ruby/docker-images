namespace :docker do
  def docker_hub_org
    "rubydata"
  end

  def docker_image_name
    "#{docker_hub_org}/ruby"
  end

  def ubuntu_version
    "bionic"
  end

  def get_ruby_trunk_head_hash
    `curl -H 'accept: application/vnd.github.v3.sha' https://api.github.com/repos/ruby/ruby/commits/trunk`.chomp
  end

  def make_tag_args(ruby_version)
    ruby_ver1 = ruby_version.split('.')[0]
    ruby_ver2 = ruby_version.split('.')[0,2].join('.')
    if ruby_version == 'trunk'
      commit_hash = get_ruby_trunk_head_hash
      ruby_version = "#{ruby_version}:#{commit_hash}"
      tags = ["trunk", "trunk-#{commit_hash}"]
    else
      tags = ["#{ruby_ver1}", "#{ruby_ver2}", "#{ruby_version}"]
    end
    tag_args = tags.map {|t| ["-t", "#{docker_image_name}:#{t}-#{ubuntu_version}"] }.flatten
    return ruby_version, tag_args
  end

  task :build do
    ruby_version = ENV['ruby_version'] || '2.5.3'
    ruby_version, tag_args = make_tag_args(ruby_version)
    sh 'docker', 'build', *tag_args, '--build-arg', "RUBY_VERSION=#{ruby_version}", '.'
  end
end
