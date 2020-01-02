# frozen_string_literal: true

module Liam
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates/', __FILE__)
    desc 'Generates the config files needed to make Liam work.'

    def copy_settings
      copy_file 'liam.yml', 'config/liam.yml'
      copy_file 'liam.rake', 'lib/tasks/liam.rake'
    end
  end
end
