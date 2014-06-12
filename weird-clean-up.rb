require 'digest/md5'
require 'FileUtils'
require 'zip/zip'

hash = {}

# Build renaming sort sequence
dir_array = []
zipcount = Time.now.to_i
Dir.glob("**_comics/*").each do |filename|
  if File.directory?(filename)
    dir_hash = {}
    chapter_int = filename.split("chapter_").last
    dir_hash[:chapter_int] = chapter_int.to_i
    dir_hash[:path] = filename
    dir_hash[:filename] = File.basename(filename)
    dir_hash[:new_name] = zipcount.to_s + "_" + dir_hash[:filename]
    zipcount = zipcount + 1
    dir_array << dir_hash
  end
end
dir_array.sort! { |x, y| y[:chapter_int] <=> x[:chapter_int]}.reverse!
puts dir_array.map{|meow| meow[:path]}.inspect

# CLEAN DUPES
Dir.glob("**_comics/*", File::FNM_DOTMATCH).each do |filename|
  # puts 'Directory:  ' + filename if File.directory?(filename)
  next if File.directory?(filename)
  # puts 'Checking ' + filename

  key = Digest::MD5.hexdigest(IO.read(filename)).to_sym
  fullpath = File.absolute_path(filename)
  if hash.has_key? key
    # puts "same file #{filename}"
    hash[key].push fullpath
  else
    hash[key] = [fullpath]
  end
end

hash.each_value do |filename_array|
  if filename_array.length > 1
    puts "=== Identical Files ===\n"
    filename_array.each { |fullpath|
      puts 'Removing:  ' + fullpath
      FileUtils.rm(fullpath)
    }
  end
end

# Rename and Rezip
dir_array.each do |directory|
  if File.exists?("saved_comics/#{directory[:filename]}.cbz")
    FileUtils.rm("saved_comics/#{directory[:filename]}.cbz")
  end
  Zip::ZipFile.open("saved_comics/" + directory[:new_name] + ".cbz", 'w') do |zipfile|
    Dir["#{directory[:path]}/**/**"].reject{|f|f==directory[:path]}.each do |file|
      zipfile.add(file.sub(directory[:path]+'/',''),file)
    end
  end
end
