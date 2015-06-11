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
      unless @xml.name == "Scan"
        raise "Invalid XML; root node must be called 'Scan'"
      end
    end

    # List of supported tags. They are all descendents of the ./Scan node.
    SUPPORTED_TAGS = [
        # attributes

        # simple tags
        :name, :short_name, :start_url, :start_time, :finish_time, :scan_time,
        :aborted, :responsive, :banner, :os, :web_server, :technologies, :ip,
        :fqdn, :operating_system, :mac_address, :netbios_name, :scan_start_time,
        :scan_stop_time
      ]

    # This allows external callers (and specs) to check for implemented
    # properties
    def respond_to?(method, include_private=false)
      return true if SUPPORTED_TAGS.include?(method.to_sym)
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
      super and return unless SUPPORTED_TAGS.include?(method)

      if tag = xml.at_xpath("./#{tag_name_for_method(method)}")
        tag.text
      else
        nil
      end
    end


    def report_items
      @xml.xpath('./ReportItems/ReportItem')
    end


    def service
      "port #{start_url_port}, #{banner}"
    end


    def start_url_host
      start_uri.host
    end
    alias_method :hostname, :start_url_host


    def start_url_port
      start_uri.port
    end

    private

    def start_uri
      @start_uri ||= URI::parse(start_url)
    end

    def tag_name_for_method(method)
      # Any fields where a simple .camelcase() won't work we need to translate,
      # this includes acronyms (e.g. :scan_url would become 'ScanUrl').
      {
        start_url: 'StartURL'
      }[method] || method.to_s.camelcase
    end

  end
end
