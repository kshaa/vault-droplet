filesystem 'persist' do
  persistant_volume_prefix = ENV['PROJECT_CODE'] ? ENV['PROJECT_CODE'] + '-' : ''
  fstype 'ext4'
  device "/dev/disk/by-id/scsi-0DO_Volume_#{persistant_volume_prefix}persist"
  mount "/mnt/persist"
  action [:create, :enable, :mount]
end
