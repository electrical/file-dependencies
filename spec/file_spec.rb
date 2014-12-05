require 'spec_helper'
require 'tmpdir'
require 'file-dependencies/file'

describe FileDependencies::File do


  describe ".calc_sha1" do

    let(:file) { Assist.generate_file('some_content') }
    it 'gives back correct sha1 value' do
      expect(FileDependencies::File.calc_sha1(file)).to eq '778164c23fae5935176254d2550619cba8abc262'
      ::File.unlink(file)
    end

    it 'raises an error when the file doesnt exist' do
      expect { FileDependencies::File.calc_sha1('dont_exist')}.to raise_error
    end
  end

  describe ".validate_sha1" do

    describe "with a sha1 string" do

      let(:file) { Assist.generate_file('some_content') }
      it 'returns true when sha11 comparing is valid' do
        remote_sha1 = '778164c23fae5935176254d2550619cba8abc262'
        expect(FileDependencies::File.validate_sha1(file, remote_sha1)).to eq true
        ::File.unlink(file)
      end

      let(:file) { Assist.generate_file('some_content') }
      it 'raises error when invalid' do
        remote_sha1 = '778164c23fae5935176254d2550619cba8abc263'
        expect { FileDependencies::File.validate_sha1(file, remote_sha1) }.to raise_error
        ::File.unlink(file)
      end

    end

    describe "With no validation" do

      let(:file) { Assist.generate_file('some_content') }
      it 'always returns true' do
        remote_sha1 = 'none'
        expect(FileDependencies::File.validate_sha1(file, remote_sha1)).to eq true
        ::File.unlink(file)
      end

    end

    describe "with a remote file" do

      let(:file) { Assist.generate_file('some_content') }
      let(:sha1file) { Assist.generate_file('778164c23fae5935176254d2550619cba8abc262') }
      let(:remote_sha1) { 'http://example.com/sha1file' }

      it 'returns true when sha11 comparing is valid' do
        expect(FileDependencies::File).to receive(:download).with(remote_sha1, Dir.tmpdir).and_return(sha1file)
        expect(FileDependencies::File.validate_sha1(file, remote_sha1)).to eq true
        ::File.unlink(file)
        ::File.unlink(sha1file)
      end

      let(:file) { Assist.generate_file('some_content') }
      let(:sha1file2) { Assist.generate_file('778164c23fae5935176254d2550619cba8abc263') }

      it 'raises error when invalid' do
        expect(FileDependencies::File).to receive(:download).with(remote_sha1, Dir.tmpdir).and_return(sha1file2)
        expect { FileDependencies::File.validate_sha1(file, remote_sha1) }.to raise_error
        ::File.unlink(file)
        ::File.unlink(sha1file2)
      end

    end
  end

  describe ".fetch_sha1" do

    describe "With a sha1 string" do
      let (:remote_sha1) { '778164c23fae5935176254d2550619cba8abc262' }
      it 'returns sha1 string when valid' do
        expect(FileDependencies::File.fetch_sha1(remote_sha1)).to eq '778164c23fae5935176254d2550619cba8abc262'
      end

      let(:faulty_remote_sha1) { '778164c23fae5935176254d2550619cba8abc2' }
      it 'raises error when sha1 string is invalid' do
        expect { FileDependencies::File.fetch_sha1(faulty_remote_sha1) }.to raise_error
      end
    end

    describe "with a remote sha1" do
      let(:sha1file) { Assist.generate_file('778164c23fae5935176254d2550619cba8abc262') }
      let(:remote_sha1) { 'http://example.com/sha1file' }

      it 'returns sha1 string when valid' do
        expect(FileDependencies::File).to receive(:download).with(remote_sha1, Dir.tmpdir).and_return(sha1file)
        expect(FileDependencies::File.fetch_sha1(remote_sha1)).to eq '778164c23fae5935176254d2550619cba8abc262'
        ::File.unlink(sha1file)
      end

      let(:sha1file2) { Assist.generate_file('778164c23fae5935176254d2550619cba8abc26') }
      it 'raises error when sha1 string is invalid' do
        expect(FileDependencies::File).to receive(:download).with(remote_sha1, Dir.tmpdir).and_return(sha1file2)
        expect { FileDependencies::File.fetch_sha1(remote_sha1) }.to raise_error
        ::File.unlink(sha1file2)
      end

    end

  end

end
