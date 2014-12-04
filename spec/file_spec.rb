require 'spec_helper'
require 'tmpdir'
require 'file-dependencies/file'

describe FileDependencies::File do

  describe "calc_sha1" do

    let(:file) { Assist.generate_file('some_content') }
    it 'gives back correct sha1 value' do
      expect(FileDependencies::File.calc_sha1(file)).to eq '778164c23fae5935176254d2550619cba8abc262'
      ::File.unlink(file)
    end

    it 'raises an error when the file doesnt exist' do
      expect { FileDependencies::File.calc_sha1('dont_exist')}.to raise_error
    end
  end

end
