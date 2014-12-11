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
    it "needs to be tested"
  end


end
