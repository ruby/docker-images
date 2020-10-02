def execute(*args)
  puts args.join(" ")
  system *args
end

while x = gets
  name, tag, = x.strip.split(",")
  name = name.split("/")[1]
  execute "docker", "tag", "rubylang/ruby:#{tag}", "ruby/ruby-docker-images/ruby:#{tag}"
end
