MINIMUM_BASE_VERSION = '2.4'

ARGF.gets # skip header
versions = {}
ARGF.each_line do |line|
  version, url, *digests = line.split(/\s+/, 5)

  next unless url.end_with?('.xz') # skip not .xz file

  _, version, preview = version.split('-')
  major, minor, micro = version.split('.')
  base_version = "#{major}.#{minor}"
  next unless base_version >= MINIMUM_BASE_VERSION

  versions[base_version] = if preview
                             "#{version}-#{preview}"
                           else
                             version
                           end
end

puts versions.values
