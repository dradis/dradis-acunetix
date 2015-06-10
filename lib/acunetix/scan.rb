module Acunetix
  # This class represents each of the /ScanGroup/Scan elements in the Acunetix
  # XML document.
  #
  # It provides a convenient way to access the information scattered all over
  # the XML in attributes and nested tags.
  #
  # Instead of providing separate methods for each supported property we rely
  # on Ruby's #method_missing to do most of the work.
  class Scan
    attr_accessor :xml
    # Accepts an XML node from Nokogiri::XML.
    def initialize(xml_node)
      @xml = xml_node
    end

    # List of supported tags. They are all desdendents of the ./HostProperties
    # node.
    def supported_tags
      [
        # attributes

        # simple tags
        :name, :short_name, :start_url, :start_time, :finish_time, :scan_time,
        :aborted, :responsive, :banner, :os, :web_server, :technologies, :ip,
        :fqdn, :operating_system, :mac_address, :netbios_name, :scan_start_time,
        :scan_stop_time
      ]
    end

    # This allows external callers (and specs) to check for implemented
    # properties
    def respond_to?(method, include_private=false)
      return true if supported_tags.include?(method.to_sym)
      super
    end

    # This method is invoked by Ruby when a method that is not defined in this
    # instance is called.
    #
    # In our case we inspect the @method@ parameter and try to find the
    # corresponding <tag/> element inside the ./Scan child.
    def method_missing(method, *args)
      # We could remove this check and return nil for any non-recognized tag.
      # The problem would be that it would make tricky to debug problems with
      # typos. For instance: <>.potr would return nil instead of raising an
      # exception
      unless supported_tags.include?(method)
        super
        return
      end

      # first we try the attributes: name
      # translations_table = {}
      # method_name = translations_table.fetch(method, method.to_s)
      # return @xml.attributes[method_name].value if @xml.attributes.key?(method_name)


      # Any fields where a simple .camelcase() won't work we need to translate,
      # this includes acronyms (e.g. :scan_url would become 'ScanUrl').
      translations_table = {
        start_url: 'StartURL'
      }
      method_name = translations_table.fetch(method, method.to_s.camelcase)

      tag = xml.at_xpath("./#{method_name}")
      if tag
        return tag.text
      else
        return nil
      end
    end
  end
end
