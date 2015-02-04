require 'qml'
require_relative 'version'
require_relative 'model'
require 'tempfile'

module SDDMConfigurationEditor
  class ConfigEditorController
    include QML::Access
    register_to_qml

    model = Model.create
    Model.merge_values(model)
    property(:model, model)

    def self.load_config
      File.read('/etc/sddm.conf')
    end
    property :config_text, load_config

    def load
      self.config_text = self.class.load_config
    end

    def save
      file = Tempfile.new('sddm-config-editor')
      file.write config_text
      file.close
      spawn 'pkexec', 'cp', file.path, '/etc/sddm.conf'
    end

    def parse(text)
      Model.merge_values(model, text)
    end

    def generate
      self.config_text = Model.generate_file(model)
    end
  end

  class ApplicationController
    include QML::Access
    register_to_qml

    def quit
      QML.application.quit
    end
  end
end

QML.run do |app|
  app.load_path 'ui/main-window.qml'
end

