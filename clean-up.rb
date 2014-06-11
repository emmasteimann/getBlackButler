require 'digest/md5'
require 'FileUtils'
require 'zip/zip'

hash = {}

Dir.glob("**/*", File::FNM_DOTMATCH).each do |filename|
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

Dir.glob("**/*").each do |filename|
  if File.directory?(filename)
    Zip::ZipFile.open(filename+".cbz", 'w') do |zipfile|
      Dir["#{filename}/**/**"].reject{|f|f==filename}.each do |file|
        zipfile.add(file.sub(filename+'/',''),file)
      end
    end
  end
end
