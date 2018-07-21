public_key_shards = %x{cat /root/id_rsa.pub}.strip.split(" ")

ssh_authorize_key public_key_shards[2] do
  key public_key_shards[1]
  user 'root'
end
