require 'spec_helper'
require 'tmpdir'
require 'file-dependencies/archive'

describe FileDependencies::Archive do

  describe ".ungzip" do
    it 'does not raise an error with correct file'do
      gzipfile = Assist.generate_gzip('some_content')
      expect { FileDependencies::Archive.ungzip(gzipfile, Dir.tmpdir) }.to_not raise_error
      expected_file = gzipfile.gsub('.gz','')
      expect(File.exist?(expected_file))
      FileUtils.remove_entry_secure(expected_file)
    end

    it 'raises error extracting non gz file' do
      gzipfile = Assist.generate_file('some_content')
      expect { FileDependencies::Archive.ungzip(gzipfile, Dir.tmpdir) }.to raise_error
      FileUtils.remove_entry_secure(gzipfile)
    end
  end

  describe ".untar" do

    it 'extracts a full tarball' do
      tarball = Assist.generate_tarball({'some/file' => 'content1', 'some/other/file' => 'content2', 'other' => 'content3'})
      entries = ['some/file', 'some/other/file', 'other' ]
      tmpdir = Stud::Temporary.pathname

      FileDependencies::Archive.untar(tarball) do |entry|
        ::File.join(tmpdir, entry.full_name)
      end
      found_files = Dir.glob(File.join(tmpdir, '**', '*')).reject! { |entry| File.directory?(entry) }.sort!
      expected_files = entries.map! { |k| "#{tmpdir}/#{k}" }.sort!
      expect(expected_files).to eq found_files
      FileUtils.remove_entry_secure tmpdir
    end

    it 'extracts some files' do
      tarball = Assist.generate_tarball({'some/file' => 'content1', 'some/other/file' => 'content2', 'other' => 'content3'})
      entries = ['some/file', 'some/other/file']
      tmpdir = Stud::Temporary.pathname

      FileDependencies::Archive.untar(tarball) do |entry|
        if entries.include?(entry.full_name)
          ::File.join(tmpdir, entry.full_name)
        end
      end
      found_files = Dir.glob(File.join(tmpdir, '**', '*')).reject! { |entry| File.directory?(entry) }.sort!
      expected_files = entries.map! { |k| "#{tmpdir}/#{k}" }.sort!
      expect(expected_files).to eq found_files
      FileUtils.remove_entry_secure tmpdir
    end

    it 'raises error when invalid file is provided' do
      tarball = Assist.generate_file('some_content')
      tmpdir = Stud::Temporary.pathname
      expect { FileDependencies::Archive.untar(tarball) do |entry|
        ::File.join(tmpdir, entry.full_name)
      end }.to raise_error
    end
  end

  describe ".eval_file" do
  end


end
