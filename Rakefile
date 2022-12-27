LATEST_UBUNTU_VERSION = "jammy"

def download(url)
  require "net/http"
  url = URI.parse(url)
  Net::HTTP.start(url.hostname, url.port, :use_ssl => (url.scheme == "https")) do |http|
    path = url.path
    path += "?#{url.query}" if url.query
    request = Net::HTTP::Get.new(url.path)
    http.request(request) do |response|
      case response
      when Net::HTTPSuccess
        return response.read_body
      else
        response.error!
      end
    end
  end
end

def default_ubuntu_version(ruby_version)
  if ruby_version < "3.0"
    "bionic"
  elsif ruby_version < "3.1"
    "focal"
  else
    "jammy"
  end
end

def ubuntu_version(ruby_version)
  ENV.fetch("ubuntu_version", default_ubuntu_version(ruby_version))
end

def ubuntu_latest_version?(ubuntu_version)
  LATEST_UBUNTU_VERSION == ubuntu_version
end

@ruby_versions = nil

def ruby_versions
  unless @ruby_versions
    require "psych"
    releases_yml = download("https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/releases.yml")
    releases = Psych.respond_to?(:unsafe_load) ? Psych.unsafe_load(releases_yml, filename: "releases.yml") : Psych.load(releases_yml, "releases.yml")
    versions = {}
    releases.each do |release|
      version = release["version"]
      ver2 = version.split('.')[0,2].join('.')
      versions[ver2] ||= []
      versions[ver2] << version
    end
    @ruby_versions = versions
  end
  @ruby_versions
end

def ruby_latest_version?(version)
  if ENV.fetch("latest_tag", "false") == "false"
    false
  else
    if not ubuntu_latest_version?(ubuntu_version(version))
      false
    else
      latest_ver2 = ruby_versions.keys.max
      ruby_versions[latest_ver2][0] == version
    end
  end
end

def ruby_latest_full_version?(version)
  ver2 = version.split('.')[0,2].join('.')
  ruby_versions[ver2][0] == version
end

def ruby_version_exist?(version)
  return true if version.start_with?("master")
  ver2 = version.split('.')[0,2].join('.')
  ruby_versions[ver2]&.include?(version)
end

namespace :debug do
  task :versions do
    pp ruby_versions
  end

  task :latest_full_version do
    ruby_version = ENV["ruby_version"]
    p latest_full_version: ruby_latest_full_version?(ruby_version)
  end

  task :version_exist do
    ruby_version = ENV["ruby_version"]
    p version_exist: ruby_version_exist?(ruby_version)
  end
end

namespace :docker do
  def docker_hub_org
    "rubylang"
  end

  def docker_image_name
    "#{docker_hub_org}/ruby"
  end

  def get_ruby_master_head_hash
    `curl -H 'accept: application/vnd.github.v3.sha' https://api.github.com/repos/ruby/ruby/commits/master`.chomp
  end

  def make_tags(ruby_version, suffix=nil, arch=nil)
    ruby_version_mm = ruby_version.split('.')[0,2].join('.')
    if /\Amaster(?::([\da-f]+))?\z/ =~ ruby_version
      commit_hash = Regexp.last_match[1] || get_ruby_master_head_hash
      ruby_version = "master:#{commit_hash}"
      tags = ["master#{suffix}", "master#{suffix}-#{commit_hash}"]
    else
      tags = ["#{ruby_version}#{suffix}"]
      tags << "#{ruby_version_mm}#{suffix}" if ruby_latest_full_version?(ruby_version)
    end
    arch &&= "-#{arch}"
    tags.collect! {|t| "#{docker_image_name}:#{t}-#{ubuntu_version(ruby_version)}#{arch}" }
    if ruby_latest_version?(ruby_version)
      tags.push "#{docker_image_name}:latest"
    else
      tags
    end
  end

  def make_tag_args(ruby_version, suffix, arch=nil)
    tag_args = make_tags(ruby_version, suffix, arch).map {|t| ["-t", t] }.flatten
    return ruby_version, tag_args
  end

  task :build do
    ruby_version = ENV['ruby_version'] || '2.6.1'
    unless ruby_version_exist?(ruby_version)
      abort "unknown ruby version: #{ruby_version}"
    end
    suffix = ENV["image_name_suffix"]
    arch = ENV["arch"]
    tag = ENV["tag"] || ""
    # NOTE: the architecture name is based on Debian ports
    # https://www.debian.org/ports/index.en.html
    case arch
    when 'arm64'
    when 'amd64', nil
      arch = nil
    else
      abort "unknown architecture name: '#{arch}'"
    end
    ruby_version, tag_args = make_tag_args(ruby_version, suffix, arch)
    if !tag.empty?
      tag_args = ["-t", "#{docker_image_name}:#{tag}"]
    end
    unless File.directory?("tmp/ruby")
      FileUtils.mkdir_p("tmp/ruby")
      IO.write('tmp/ruby/.keep', '')
    end
    env_args = %w(cppflags optflags).map {|name| ["--build-arg", "#{name}=#{ENV[name]}"] }.flatten
    sh 'docker', 'build', '-f', 'Dockerfile', *tag_args, *env_args,
       '--build-arg', "RUBY_VERSION=#{ruby_version}",
       '--build-arg', "BASE_IMAGE_TAG=#{ubuntu_version(ruby_version)}",
       '.'
    if ruby_version.start_with? 'master'
      image_name = tag_args[3]
      if ENV['nightly']
        today = Time.now.utc.strftime('%Y%m%d')
        sh 'docker', 'tag', image_name, image_name.sub(/master#{suffix}-([\da-f]+)/, "master#{suffix}-nightly-#{today}")
        sh 'docker', 'tag', image_name, image_name.sub(/master#{suffix}-([\da-f]+)/, "master#{suffix}-nightly")
      end
    end
  end

  namespace :manifest do
    task :create do
      ruby_version = ENV.fetch("ruby_version")
      ubuntu_version = ENV.fetch("ubuntu_version")
      architectures = ENV.fetch("architectures").split(' ')
      manifest_suffix = ENV.fetch("manifest_suffix", nil)

      tags = make_tags(ruby_version)

      amend_args = architectures.map {|arch|
        manifest_name = "#{tags[0]}-#{arch}"
        manifest_name = "#{manifest_name}-#{manifest_suffix}" if manifest_suffix
        ['--amend', manifest_name]
      }.flatten

      tags.each do |tag|
        sh 'docker', 'manifest', 'create', "#{tag}", *amend_args
      end
    end

    task :push do
      ruby_version = ENV["ruby_version"]

      tags = make_tags(ruby_version)

      tags.each do |tag|
        sh 'docker', 'manifest', 'push', "#{tag}"
      end
    end
  end
end
