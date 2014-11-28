require 'json'

module FileDependencies
  module Gem
    extend self

    def hook
      Gem.post_install do |gem_installer|
        next if ENV['VENDOR_SKIP'] == 'true'
        FileDependencies.process_vendor(gem_installer.gem_dir)
      end
    end # def hook

  end
end
