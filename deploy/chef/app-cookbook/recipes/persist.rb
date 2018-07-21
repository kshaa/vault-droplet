persistant_volume_prefix = ENV['PROJECT_CODE'] ? ENV['PROJECT_CODE'] + '-' : ''
persistant_volume_device = '/dev/disk/by-id/scsi-0DO_Volume_#{persistance_volume_prefix}persist'
persistant_volume_mount  = '/mnt/persist'

puts "Persistant volume device - '#{persistant_volume_device}'"
puts "Persistant volume mount - '#{persistant_volume_mount}'"

filesystem 'persist' do
  fstype 'ext4'
  device persistant_volume_device
  mount persistant_volume_mount
  action [:create, :enable, :mount]
end
