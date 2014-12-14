require "archive/tar/minitar"
require "fileutils"

module FileDependencies
  # :nodoc:
  module Archive
    def ungzip(file, outdir)
      output = ::File.join(outdir, file.gsub('.gz', '').split("/").last)
      tgz = Zlib::GzipReader.new(::File.open(file))
      begin
        ::File.open(output, "w") do |out|
          IO.copy_stream(tgz, out)
        end
        ::File.unlink(file)
      rescue
        ::File.unlink(output) if ::File.file?(output)
        raise
      end
      tgz.close
    end
    module_function :ungzip

    def untar(tarball, &block)
      tgz = Zlib::GzipReader.new(::File.open(tarball))
      tar = ::Archive::Tar::Minitar::Input.open(tgz)
      tar.each do |entry|
        path = block.call(entry)
        next if path.nil?
        parent = ::File.dirname(path)

        FileUtils.mkdir_p(parent) unless ::File.directory?(parent)

        # Skip this file if the output file is the same size
        if entry.directory?
          FileUtils.mkdir_p(path) unless ::File.directory?(path)
        else
          entry_mode = entry.instance_eval { @mode } & 0777
          if ::File.exist?(path)
            stat = ::File.stat(path)
            # TODO(sissel): Submit a patch to archive-tar-minitar upstream to
            # expose headers in the entry.
            entry_size = entry.instance_eval { @size }
            # If file sizes are same, skip writing.
            next if stat.size == entry_size && (stat.mode & 0777) == entry_mode
          end
          puts "Extracting #{entry.full_name} from #{tarball} #{entry_mode.to_s(8)}" if $DEBUG
          ::File.open(path, "w") do |fd|
            # eof? check lets us skip empty files. Necessary because the API provided by
            # Archive::Tar::Minitar::Reader::EntryStream only mostly acts like an
            # IO object. Something about empty files in this EntryStream causes
            # IO.copy_stream to throw "can't convert nil into String" on JRuby
            # TODO(sissel): File a bug about this.
            until entry.eof?
              chunk = entry.read(16_384)
              fd.write(chunk)
            end
            # IO.copy_stream(entry, fd)
          end
          ::File.chmod(entry_mode, path)
        end
      end
      tar.close
      ::File.unlink(tarball) if ::File.file?(tarball)
    end # def untar
    module_function :untar

    def eval_file(entry, files, prefix)
      return false if tar_header?(entry)
      if files.is_a?(Array)
        return true if files.include?(entry.gsub(prefix, ''))
      elsif files.is_a?(String)
        return true if entry =~ Regexp.new(files)
      end
      false
    end
    module_function :eval_file

    def tar_header?(entry)
      entry =~ /PaxHeaders/
    end
    module_function :tar_header?
  end
end
