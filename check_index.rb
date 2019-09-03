MINIMUM_BASE_VERSION = '2.4'

ARGF.gets # skip header
versions = {}
ARGF.each_line do |line|
  version, url, *digests = line.split(/\s+/, 5)

  $stderr.puts url
  next unless url.end_with?('.xz') # skip not .xz file

  _, version, preview = version.split('-')
  major, minor, micro = version.split('.')
  base_version = "#{major}.#{minor}"
  $stderr.puts base_version
  next unless base_version >= MINIMUM_BASE_VERSION

  full_version = "#{version}-#{preview}" if preview
  versions[base_version] = full_version
end

puts versions.values
