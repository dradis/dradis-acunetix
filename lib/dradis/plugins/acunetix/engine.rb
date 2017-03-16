module Dradis::Plugins::Acunetix
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Acunetix

    include ::Dradis::Plugins::Base
    description 'Processes Acunetix XML format'
    provides :upload
  end
end
