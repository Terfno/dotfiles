# verndor from: https://github.com/k0kubun/dotfiles/blob/bf7e5c3a456bad3824d8bbab1e61d8893070a2b0/recipes/base/default.rb
# original license: MIT, https://github.com/k0kubun/dotfiles/blob/bf7e5c3a456bad3824d8bbab1e61d8893070a2b0/LICENSE.txt

LINKS = lambda do |name|
  if name.is_a?(String)
    { name => name }
  else
    name
  end
end

PREFIXED_LINKS = lambda do |prefix, name|
  LINKS.call(name).transform_keys { |link_from| File.join(prefix, link_from) }
end

BACKUP_PATH = lambda do |path|
  candidate = "#{path}.local"
  suffix = 0

  while File.exist?(candidate) || File.symlink?(candidate)
    suffix += 1
    candidate = "#{path}.local.#{suffix}"
  end

  candidate
end

define :dotfile do
  # create symbolic link from ~/link_from to dotfiles/config/link_to .
  LINKS.call(params[:name]).each do |link_from, link_to|
    directory File.dirname(link_from = File.join(ENV['HOME'], link_from)) do
      user node[:user]
    end

    File.rename(link_from, BACKUP_PATH.call(link_from)) if File.exist?(link_from) && !File.symlink?(link_from)

    link link_from do
      to File.expand_path("../../config/#{link_to}", __FILE__)
      user node[:user]
      force true
    end
  end
end

define :xdg do
  dotfile PREFIXED_LINKS.call('.config', params[:name])
end

define :brew_cask do
  name = params[:name]

  installed = run_command("brew list --cask '#{name}'", error: false).exit_status == 0

  if installed
    puts " INFO : [brew_cask] #{name} is already installed"
  else
    puts " INFO : [brew_cask] #{name} will be installed"
  end

  execute "install cask: #{name}" do
    command "brew install --cask '#{name}'"
    not_if  "brew list --cask '#{name}'"
    user node[:user]
  end
end
