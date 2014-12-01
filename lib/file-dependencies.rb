require 'file-dependencies/file'
require 'file-dependencies/archive'
require 'json'

module FileDependencies
  extend self

  def process_vendor(dir, target='vendor')
    vendor_file = ::File.join(dir, 'vendor.json')
    if ::File.exist?(vendor_file)
      vendor_file_content = IO.read(vendor_file)
      file_list = Json.load(vendor_file_content)
      FileDependencies.download(file_list, ::File.join(dir, target))
    else
      puts "vendor.json not found, looked for the file at #{vendor_file}"
    end
  end # def process_vendor

  def download(files, target='')

    FileUtils.mkdir_p(target) unless ::File.directory?(target)

    files.each do |file|
      download = FileDependencies::File.fetch_file(file['url'], file['sha1'],target)

      if download =~ /(\S+?)(\.tar\.gz|\.tgz)/
        prefix = $1.gsub("#{target}/", '')
        FileDependencies::Archive.untar(download) do |entry|
          next unless out = FileDependencies::Archive.eval_file(entry, file['files'], prefix)
          File.join(target, out)
        end
      elsif download =~ /.gz/
        FileDependencies::Archive.ungzip(download)
      end
    end
  end # def download

end
