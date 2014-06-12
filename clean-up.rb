require 'digest/md5'
require 'FileUtils'
require 'zip/zip'

hash = {}

Dir.glob("**_comics/*", File::FNM_DOTMATCH).each do |filename|
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

Dir.glob("**_comics/*").each do |filename|
  if File.directory?(filename)
    original_filename = filename.split("_comics/").last
    chapter_parts = filename.split("chapter_")
    chapter_int = chapter_parts.last.to_i
    chapter_int_string = chapter_int < 10 ? "0" + chapter_int.to_s : chapter_int.to_s

    reassembled_filename = chapter_parts.first.split("_comics/").last + "chapter_"+ chapter_int_string

    if File.exists?("saved_comics/#{original_filename}.cbz")
      FileUtils.rm("saved_comics/#{original_filename}.cbz")
    end
    Zip::ZipFile.open("saved_comics/" + reassembled_filename + ".cbz", 'w') do |zipfile|
      Dir["#{filename}/**/**"].reject{|f|f==filename}.each do |file|
        zipfile.add(file.sub(filename+'/',''),file)
      end
    end
  end
end
