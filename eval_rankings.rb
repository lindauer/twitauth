#!/usr/bin/env ruby

# Outputs rank and test account name for each test account.
# Output is ready to sort and feed to a CDF plotter.

require 'ap'

rankings_dir = './rankings'
map_file = './model/map.csv'
dups_file = './twitter-dups.txt'

id_map = Hash[]
correct = Hash[] # Ground truth

# Read map
File.open(map_file).each do |line|
  i, name = line.chomp!.split(",")
  i = i.to_i
  name.gsub!(/.csv$/, "").downcase!
  id_map[name] = i
  id_map[i] = name
end

# Read answer key
File.open(dups_file).each do |line|
  names = line.chomp!.split(',').map{|n| n.downcase}
  names.combination(2).each do |pair|
    correct[pair.sort.join(',')] = 1
    correct[pair.map{|i| id_map[i]}.sort.join(',')] = 1
  end
end

# Read results
Dir.glob("#{rankings_dir}/*.csv").each do |rfile|
  rfile_base = File.basename(rfile).gsub(/.csv$/, '').downcase
  rfile_id = id_map[rfile_base] || abort("Id not found for #{rfile_base}")
  seen_self = false
  File.open(rfile).each_with_index do |line, rank|
    id = line.split(",")[0].to_i
    seen_self = true if (id == rfile_id)
    if (correct[[rfile_id, id].sort.join(',')])
      rank -= 1 if seen_self
      rank += 1 # was zero-indexed
      puts "#{rank},#{rfile_base}"
      break
    end
  end
end

exit 0
