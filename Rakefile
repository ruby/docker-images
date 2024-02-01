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

def default_ruby_version
  ENV['ruby_version'] || '3.3.0'
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

def ruby_latest_stable_version
  ruby_versions.keys.sort.reverse.each do |ver2|
    ruby_versions[ver2].sort.reverse.each do |ver|
      if ver.match?(/\A\d+\.\d+\.\d+\z/)
        return ver
      end
    end
  end
  nil
end

def ruby_latest_version?(version)
  if ENV.fetch("latest_tag", "false") == "false"
    false
  else
    if not ubuntu_latest_version?(ubuntu_version(version))
      false
    else
      version == ruby_latest_stable_version
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

  task :latest_stable_version do
    p latest_stable_version: ruby_latest_stable_version
  end

  task :latest_version do
    ENV["latest_tag"] = "true"
    ruby_version = ENV["ruby_version"]
    p latest_version: ruby_latest_version?(ruby_version)
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
  def registry_name
    ENV.fetch("registry_name", "rubylang")
  end

  def docker_image_name
    "#{registry_name}/ruby"
  end

  def get_ruby_master_head_hash
    # Use the same hash throughout the same CircleCI job
    if ENV.key?('CIRCLE_BUILD_NUM') && File.exist?(cache_path = "/tmp/ruby-docker-images.#{ENV['CIRCLE_BUILD_NUM']}")
      return File.read(cache_path)
    end

    head_hash = `curl -H 'accept: application/vnd.github.v3.sha' https://api.github.com/repos/ruby/ruby/commits/master`.chomp
    if cache_path
      File.write(cache_path, head_hash)
    end
    head_hash
  end

  def get_ruby_version_at_commit(commit_hash)
    raise ArgumentError, "Invalid commit_hash: #{commit_hash.inspect}" unless commit_hash.match?(/\A[a-z0-9]+\z/)
    version_h = download("https://raw.githubusercontent.com/ruby/ruby/#{commit_hash}/include/ruby/version.h")
    version_info = {}
    version_h.each_line do |line|
      case line
      when /\A#define RUBY_[A-Z_]*VERSION_([A-Z][A-Z][A-Z_0-9]*) (\d\d*)$/
        version_info[$1.to_sym] = $2
      end
    end
    return version_info
  end

  def make_tags(ruby_version, version_suffix=nil, tag_suffix=nil)
    ruby_version_mm = ruby_version.split('.')[0,2].join('.')
    if /\Amaster(?::([\da-f]+))?\z/ =~ ruby_version
      commit_hash = Regexp.last_match[1] || get_ruby_master_head_hash
      ruby_version = "master:#{commit_hash}"
      tags = ["master#{version_suffix}", "master#{version_suffix}-#{commit_hash}"]
    else
      tags = ["#{ruby_version}#{version_suffix}"]
      tags << "#{ruby_version_mm}#{version_suffix}" if ruby_latest_full_version?(ruby_version)
    end
    tags.collect! {|t| "#{docker_image_name}:#{t}-#{ubuntu_version(ruby_version)}#{tag_suffix}" }
    tags.push "#{docker_image_name}:latest" if ruby_latest_version?(ruby_version)
    return ruby_version, tags
  end

  def each_nightly_tag(ruby_version, tags)
    return [] unless ENV.key?('nightly') && ruby_version.start_with?('master:')
    commit_hash = ruby_version.split(":")[1]
    commit_hash_re = /\b#{Regexp.escape(commit_hash)}\b/
    image_name = tags.find {|x| x.match? commit_hash_re }
    today = Time.now.utc.strftime('%Y%m%d')
    yield image_name, image_name.sub(commit_hash_re, "nightly-#{today}")
    yield image_name, image_name.sub(commit_hash_re, "nightly")
  end

  task :build do
    ruby_version = default_ruby_version
    unless ruby_version_exist?(ruby_version)
      abort "unknown ruby version: #{ruby_version}"
    end
    version_suffix = ENV["image_version_suffix"]
    tag_suffix = ENV["tag_suffix"]
    tag = ENV["tag"] || ""
    target = ENV.fetch("target", "ruby")
    arch = ENV.fetch("arch", "linux/amd64")

    ruby_version, tags = make_tags(ruby_version, version_suffix, tag_suffix)
    tags << "#{docker_image_name}:#{tag}" if !tag.empty?

    build_args = [
      "RUBY_VERSION=#{ruby_version}",
      "BASE_IMAGE_TAG=#{ubuntu_version(ruby_version)}"
    ]
    if ruby_version.start_with?("master:")
      commit_hash = ruby_version.split(":")[1]
      version_info = get_ruby_version_at_commit(commit_hash)
      ruby_so_suffix = version_info.values_at(:MAJOR, :MINOR, :TEENY).join(".")
      build_args << "RUBY_SO_SUFFIX=#{ruby_so_suffix}"
    end
    %w(cppflags optflags).each do |name|
      build_args << %Q(#{name}=#{ENV[name]}) if ENV.key?(name)
    end

    unless File.directory?("tmp/ruby")
      FileUtils.mkdir_p("tmp/ruby")
      IO.write('tmp/ruby/.keep', '')
    end

    build_cmd_args = arch =~ /arm/ ? ['buildx', 'build', '--platform', arch] : ['build']

    sh 'docker', *build_cmd_args, '-f', 'Dockerfile',
       *tags.map {|tag| ["-t", tag] }.flatten,
       *build_args.map {|arg| ["--build-arg", arg] }.flatten,
       '--target', target,
       '.'

    sh 'docker', 'images'

    each_nightly_tag(ruby_version, tags) do |image_name, tag|
      sh 'docker', 'tag', image_name, tag
    end
  end

  task :push do
    ruby_version = ENV['ruby_version'] || '2.6.1'
    unless ruby_version_exist?(ruby_version)
      abort "unknown ruby version: #{ruby_version}"
    end
    version_suffix = ENV["image_version_suffix"]
    tag_suffix = ENV["tag_suffix"]
    tag = ENV["tag"] || ""
    target = ENV.fetch("target", "ruby")
    ruby_version, tags = make_tags(ruby_version, version_suffix, tag_suffix)

    tags.each do |tag|
      sh 'docker', 'push', tag
    end

    each_nightly_tag(ruby_version, tags) do |_, tag|
      sh 'docker', 'push', tag
    end
  end

  namespace :manifest do
    task :create do
      ruby_version = ENV.fetch("ruby_version")
      ubuntu_version = ENV.fetch("ubuntu_version")
      architectures = ENV.fetch("architectures").split(' ')
      manifest_suffix = ENV.fetch("manifest_suffix", nil)
      image_version_suffix = ENV["image_version_suffix"]

      _, tags = make_tags(ruby_version, image_version_suffix)

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
      image_version_suffix = ENV["image_version_suffix"]

      _, tags = make_tags(ruby_version, image_version_suffix)

      tags.each do |tag|
        sh 'docker', 'manifest', 'push', "#{tag}"
      end
    end
  end
end
