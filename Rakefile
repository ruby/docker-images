namespace :docker do
  def docker_hub_org
    "rubylang"
  end

  def docker_image_name
    "#{docker_hub_org}/ruby"
  end

  def ubuntu_version
    "bionic"
  end

  def get_ruby_master_head_hash
    `curl -H 'accept: application/vnd.github.v3.sha' https://api.github.com/repos/ruby/ruby/commits/master`.chomp
  end

  def make_tag_args(ruby_version, suffix, arch=nil)
    ruby_ver2 = ruby_version.split('.')[0,2].join('.')
    if /\Amaster(?::([\da-f]+))?\z/ =~ ruby_version
      commit_hash = Regexp.last_match[1] || get_ruby_master_head_hash
      ruby_version = "master:#{commit_hash}"
      tags = ["master#{suffix}", "master#{suffix}-#{commit_hash}"]
    else
      tags = ["#{ruby_ver2}#{suffix}", "#{ruby_version}#{suffix}"]
    end
    arch = "-#{arch}" if arch
    tag_args = tags.map {|t| ["-t", "#{docker_image_name}:#{t}-#{ubuntu_version}#{arch}"] }.flatten
    return ruby_version, tag_args
  end

  task :build do
    ruby_version = ENV['ruby_version'] || '2.6.1'
    suffix = ENV["image_name_suffix"]
    arch = ENV["arch"]
    # NOTE: the architecture name is based on Debian ports
    # https://www.debian.org/ports/index.en.html
    case arch
    when 'arm64'
      dockerfile = 'Dockerfile-arm64'
    when 'amd64', nil
      arch = nil
      dockerfile = 'Dockerfile'
    else
      abort "unknown architecture name: '#{arch}'"
    end
    ruby_version, tag_args = make_tag_args(ruby_version, suffix, arch)
    unless File.directory?("tmp/ruby")
      FileUtils.mkdir_p("tmp/ruby")
      IO.write('tmp/ruby/.keep', '')
    end
    env_args = %w(cppflags optflags).map {|name| ["--build-arg", "#{name}=#{ENV[name]}"] }.flatten
    sh 'docker', 'run', '--rm', '--privileged', 'multiarch/qemu-user-static:register', '--reset' if arch
    sh 'docker', 'build', '-f', dockerfile, '--security-opt', 'seccomp=unconfined', *tag_args, *env_args, '--build-arg', "RUBY_VERSION=#{ruby_version}", '.'
    if ruby_version.start_with? 'master'
      image_name = tag_args[3]
      if ENV['nightly']
        today = Time.now.getlocal("+09:00").strftime('%Y%m%d')
        sh 'docker', 'tag', image_name, image_name.sub(/master#{suffix}-([\da-f]+)/, "master#{suffix}-nightly-#{today}")
        sh 'docker', 'tag', image_name, image_name.sub(/master#{suffix}-([\da-f]+)/, "master#{suffix}-nightly")
      end
    end
  end
end
