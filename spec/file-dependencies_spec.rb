require 'spec_helper'
require 'tmpdir'
require 'json'
require 'file-dependencies'

include WebMock::API
describe FileDependencies do

  describe '.download' do
    after do
      [tmpdir, target, file1, file2, file3, file4].each do |entry|
        FileUtils.remove_entry_secure(entry)
      end
    end

    let(:tmpdir) { Stud::Temporary.directory }
    let(:target) { Stud::Temporary.directory }

    let(:file1) { Assist.generate_tarball({'some/file' => 'content1', 'some/other/file' => 'content2', 'other' => 'content3'}) }
    let(:file2) { Assist.generate_file('some_content') }
    let(:file3) { Assist.generate_gzip('some_content_for_gzip') }
    let(:file4) { Assist.generate_tarball({'jars/some.jar' => 'content10', 'jars/someother.jar' => 'content11'}) }

    let(:sha1) { FileDependencies::File.calc_sha1(file1) }
    let(:sha2) { FileDependencies::File.calc_sha1(file2) }
    let(:sha3) { FileDependencies::File.calc_sha1(file3) }
    let(:sha4) { FileDependencies::File.calc_sha1(file4) }

    let(:url1) { 'http://www.example.com/somefile1.tar.gz' }
    let(:url2) { 'http://www.example.com/somefile2.txt' }
    let(:url3) { 'http://www.example.com/somefile3.gz' }
    let(:url4) { 'http://www.example.com/somefile4.tar.gz' }

    let(:entries) { ['somefile2.txt', 'somefile3', 'some/file', 'some/other/file', 'other', 'jars/some.jar', 'jars/someother.jar'] }

    let(:files) { [ { 'url' => url1, 'sha1' => sha1 }, { 'url' => url2, 'sha1' => sha2 }, { 'url' => url3, 'sha1' => sha3 }, { 'url' => url4, 'sha1' => sha4, 'extract' => '.jar', 'target' => 'jars' } ] }

    it 'processes file list' do
      stub_request(:get, url1).to_return(:body => File.new(file1), :status => 200)
      stub_request(:get, url2).to_return(:body => File.new(file2), :status => 200)
      stub_request(:get, url3).to_return(:body => File.new(file3), :status => 200)
      stub_request(:get, url4).to_return(:body => File.new(file4), :status => 200)
     
      # we should not have any errors
      expect{ FileDependencies.download(files, target, tmpdir) }.to_not(raise_error)

      # check if we got all the expected files
      found_files = Dir.glob(File.join(target, '**', '*')).reject { |entry| File.directory?(entry) }.sort
      expect_files = entries.map { |k| ::File.join(target, k) }.sort
      expect(found_files).to(eq(expect_files))
      
    end
  end

  describe '.process_vendor' do
    after do
      [tmpdir, target, file1, file2, file3, file4].each do |entry|
        FileUtils.remove_entry_secure(entry)
      end
    end

    let(:tmpdir) { Stud::Temporary.directory }
    let(:target) { Stud::Temporary.directory }

    let(:file1) { Assist.generate_tarball({'some/file' => 'content1', 'some/other/file' => 'content2', 'other' => 'content3'}) }
    let(:file2) { Assist.generate_file('some_content') }
    let(:file3) { Assist.generate_gzip('some_content_for_gzip') }
    let(:file4) { Assist.generate_tarball({'jars/some.jar' => 'content10', 'jars/someother.jar' => 'content11'}) }

    let(:sha1) { FileDependencies::File.calc_sha1(file1) }
    let(:sha2) { FileDependencies::File.calc_sha1(file2) }
    let(:sha3) { FileDependencies::File.calc_sha1(file3) }
    let(:sha4) { FileDependencies::File.calc_sha1(file4) }

    let(:url1) { 'http://www.example.com/somefile1.tar.gz' }
    let(:url2) { 'http://www.example.com/somefile2.txt' }
    let(:url3) { 'http://www.example.com/somefile3.gz' }
    let(:url4) { 'http://www.example.com/somefile4.tar.gz' }

    let(:files) { [ { 'url' => url1, 'sha1' => sha1 }, { 'url' => url2, 'sha1' => sha2 }, { 'url' => url3, 'sha1' => sha3 }, { 'url' => url4, 'sha1' => sha4, 'extract' => '.jar', 'target' => 'jars' } ].to_json }
    let(:vendorfile) { File.write(File.join(target, 'vendor.json'), files) }
    let(:entries) { ['somefile2.txt', 'somefile3', 'some/file', 'some/other/file', 'other', 'jars/some.jar', 'jars/someother.jar'] }

    it 'processes the vendor.json file' do
      stub_request(:get, url1).to_return(:body => File.new(file1), :status => 200)
      stub_request(:get, url2).to_return(:body => File.new(file2), :status => 200)
      stub_request(:get, url3).to_return(:body => File.new(file3), :status => 200)
      stub_request(:get, url4).to_return(:body => File.new(file4), :status => 200)
      File.write(File.join(target, 'vendor.json'), files)
     
      # we should not have any errors
      expect{ FileDependencies.process_vendor(target, 'vendor', tmpdir) }.to_not(raise_error)

      # check if we got all the expected files
      found_files = Dir.glob(File.join(target, 'vendor', '**', '*')).reject { |entry| File.directory?(entry) }.sort
      expect_files = entries.map { |k| ::File.join(target, 'vendor', k) }.sort
      expect(found_files).to(eq(expect_files))
      
    end

  end

end
