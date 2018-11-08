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
    ruby_ver2 = ruby_version.split('.')[0,2].join('.')
    if /\Atrunk(?::([\da-f]+))?\z/ =~ ruby_version
      commit_hash = Regexp.last_match[1] || get_ruby_trunk_head_hash
      ruby_version = "trunk:#{commit_hash}"
      tags = ["trunk", "trunk-#{commit_hash}"]
    else
      tags = ["#{ruby_ver2}", "#{ruby_version}"]
    end
    tag_args = tags.map {|t| ["-t", "#{docker_image_name}:#{t}-#{ubuntu_version}"] }.flatten
    return ruby_version, tag_args
  end

  task :build do
    ruby_version = ENV['ruby_version'] || '2.5.3'
    ruby_version, tag_args = make_tag_args(ruby_version)
    unless File.directory?("tmp/ruby")
      FileUtils.mkdir_p("tmp/ruby")
      IO.write('tmp/ruby/.keep', '')
    end
    sh 'docker', 'build', *tag_args, '--build-arg', "RUBY_VERSION=#{ruby_version}", '.'
    if ruby_version.start_with? 'trunk'
      image_name = tag_args[3]
      svn_revision = `docker run --rm #{tag_args[3]} ruby -e 'puts RUBY_DESCRIPTION[/trunk (\\d+)/, 1]'`.chomp
      sh 'docker', 'tag', image_name, image_name.sub(/trunk-([\da-f]+)/, "trunk-r#{svn_revision}")
      if ENV['nightly']
        today = Time.now.getlocal("+09:00").strftime('%Y%m%d')
        sh 'docker', 'tag', image_name, image_name.sub(/trunk-([\da-f]+)/, "trunk-nightly-#{today}")
        sh 'docker', 'tag', image_name, image_name.sub(/trunk-([\da-f]+)/, "trunk-nightly")
      end
    end
  end
end
