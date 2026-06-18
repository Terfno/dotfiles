# generate.rb
require "erb"

File.readlines(".env", chomp: true).each do |line|
  next if line.empty? || line.start_with?("#")

  key, value = line.split("=", 2)
  ENV[key] = value
end

def env!(key)
  ENV.fetch(key)
end

template = File.read("template.conf.erb")
result = ERB.new(template).result(binding)

File.write("rclone.conf", result)
