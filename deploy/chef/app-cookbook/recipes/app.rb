images_path = '/mnt/persist/images'

ruby 'load up images' do
  cwd images_path

  only_if { File.exists? images_path }

  code <<-EOF
    Dir.glob('fresh/*').each do |image|
      name = File.basename image
      next if File.exists?("loaded/\#{ name }")

      out = IO.popen(%w{docker load -i} + [image], :err=>[:child, :out], &:read)
      raise "\#{ $0 }: docker load -i failed\\n\\n\#{ out }\\n\\n, btw pwd: \#{ %w{docker load -i} + [image] }" unless $?.success?

      File.rename(image, File.join('loaded', name))
      File.open(image, 'w') {}
    end
  EOF
end

# Initialise persistent storage for audits and secrets
execute "storage mounting" do
  command "mkdir -p /etc/deployment/storage/logs; mkdir -p /etc/deployment/storage/secrets; ln -s /mnt/persist /etc/deployment/storage"
end

# Docker container initialisation
execute "docker composition" do
  command "docker-compose --file /var/deployment/docker-compose.yml up -d"
end

# Docker container logging 
execute "docker logging" do
  command "docker-compose logs -f --no-color |& tee -a '/etc/deployment/storage/logs/vault-$(date +%s).log'"
end
