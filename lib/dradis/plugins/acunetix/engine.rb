module Dradis::Plugins::Acunetix
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Acunetix

    include ::Dradis::Plugins::Base
    description 'Processes Acunetix XML format'
    provides :upload

    # Configuring the gem
    # class Configuration < Core::Configurator
    #   configure :namespace => 'burp'
    #   setting :category, :default => 'Burp Scanner output'
    #   setting :author, :default => 'Burp Scanner plugin'
    # end
  end
end
