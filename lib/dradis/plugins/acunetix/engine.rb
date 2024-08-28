module Dradis::Plugins::Acunetix
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Acunetix

    include ::Dradis::Plugins::Base
    description 'Processes Acunetix XML format'
    provides :upload

    # Because this plugin provides two export modules, we have to overwrite
    # the default .uploaders() method.
    #
    # See:
    #  Dradis::Plugins::Upload::Base in dradis-plugins
    def self.uploaders
      [
        Dradis::Plugins::Acunetix::Standard,
        Dradis::Plugins::Acunetix::Acunetix360
      ]
    end
  end
end
