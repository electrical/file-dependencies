require 'spec_helper'
require 'tmpdir'
require 'file-dependencies/archive'

describe FileDependencies::Archive do

  describe ".ungzip" do

    after do
      FileUtils.remove_entry_secure(gzipfile) if ::File.exist?(gzipfile)
      FileUtils.remove_entry_secure(expected_file)
      FileUtils.remove_entry_secure(tmpdir)
    end
    let(:gzipfile) { Assist.generate_gzip('some_content') }
    let(:expected_file) { gzipfile.gsub('.gz','') }
    let(:tmpdir) { Stud::Temporary.directory }

    it 'does not raise an error with correct file'do
      expect { FileDependencies::Archive.ungzip(gzipfile, tmpdir) }.to_not(raise_error)
      expect(File.exist?(expected_file))
    end

    let(:expected_file) { Assist.generate_file('some_content') }
    it 'raises error extracting non gz file' do
      expect { FileDependencies::Archive.ungzip(expected_file, tmpdir) }.to(raise_error(Zlib::GzipFile::Error))
    end
  end

  describe ".untar" do

    after do
      FileUtils.remove_entry_secure(tmpdir)
      FileUtils.remove_entry_secure(file)
    end

    let(:file) { Assist.generate_file('some_content') }
    let(:tarball) { Assist.generate_tarball({'some/file' => 'content1', 'some/other/file' => 'content2', 'other' => 'content3'}) }
    let(:tmpdir) { Stud::Temporary.directory }

    it 'extracts a full tarball' do
      entries = ['some/file', 'some/other/file', 'other' ]

      FileDependencies::Archive.untar(tarball) do |entry|
        ::File.join(tmpdir, entry.full_name)
      end
      found_files = Dir.glob(File.join(tmpdir, '**', '*')).reject! { |entry| File.directory?(entry) }.sort!
      expected_files = entries.map! { |k| "#{tmpdir}/#{k}" }.sort!
      expect(expected_files).to(eq(found_files))
    end

    it 'extracts some files' do
      entries = ['some/file', 'some/other/file']

      FileDependencies::Archive.untar(tarball) do |entry|
        if entries.include?(entry.full_name)
          ::File.join(tmpdir, entry.full_name)
        end
      end
      found_files = Dir.glob(File.join(tmpdir, '**', '*')).reject! { |entry| File.directory?(entry) }.sort!
      expected_files = entries.map! { |k| "#{tmpdir}/#{k}" }.sort!
      expect(expected_files).to(eq(found_files))
    end

    it 'raises error when invalid file is provided' do
      expect do
        FileDependencies::Archive.untar(file) do |entry|
          ::File.join(tmpdir, entry.full_name)
        end
      end.to(raise_error(Zlib::GzipFile::Error))
    end
  end

  describe ".eval_file" do

    # Hack to implement the full_name part
    class ::String
      def full_name
        return self
      end
    end

    let(:entries) { [ 'sometar/PaxHeaders', 'sometar/some/dir/PaxHeaders', 'sometar/some/dir/somefile', 'sometar/somefile', 'sometar/some/other/file', 'sometar/some/jars/file1.jar', 'sometar/some/jars/file2.jar', 'sometar/other/jars/file3.jar' ]}
    let(:prefix) { 'sometar' }

    let(:extract1) { '.jars' } #wildcard
    let(:expect1) { [ 'file1.jar', 'file2.jar', 'file3.jar'] }
    let(:extract2) { ['/some/other/file', '/somefile', '/other/jars/file3.jar' ]}
    let(:expect2) { ['file', 'somefile', 'file3.jar' ]}
    let(:extract3) { }
    let(:expect3) { [ '/some/dir/somefile', '/somefile', '/some/other/file', '/some/jars/file1.jar', '/some/jars/file2.jar', '/other/jars/file3.jar' ] }

    it 'returns all files based on a wildcard' do
      filelist = []
      entries.each do |entry|
        filelist << FileDependencies::Archive.eval_file(entry, extract1, prefix)
      end
      expect(filelist.reject{ |v| v == false}.sort).to(eq(expect1.sort))
    end

    it 'returns all files based on an array' do
      filelist = []
      entries.each do |entry|
        filelist << FileDependencies::Archive.eval_file(entry, extract2, prefix)
      end
      expect(filelist.reject{ |v| v == false}.sort).to(eq(expect2.sort))
    end

    it 'returns all files when no extracted files are given' do
      filelist = []
      entries.each do |entry|
        filelist << FileDependencies::Archive.eval_file(entry, extract3, prefix)
      end
      expect(filelist.reject{ |v| v == false}.sort).to(eq(expect3.sort))
    end

  end

end
