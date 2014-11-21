module Dradis
  module Plugins
    module Acunetix
    end
  end
end

require 'dradis/plugins/acunetix/engine'
require 'dradis/plugins/acunetix/field_processor'
require 'dradis/plugins/acunetix/importer'
require 'dradis/plugins/acunetix/version'


# This is required while we transition the Upload Manager to use
# Dradis::Plugins only
module Dradis
  module Plugins
    module Acunetix
      module Meta
        NAME = "Acunetix XML upload plugin"
        EXPECTS = "Acunetix XML format."
        module VERSION
          include Dradis::Plugins::Acunetix::VERSION
        end
      end
    end
  end
end
