module Acunetix
  # This class represents each of the /ScanGroup/Scan/ReportItems/ReportItem
  # elements in the Acunetix XML document.
  #
  # It provides a convenient way to access the information scattered all over
  # the XML in attributes and nested tags.
  #
  # Instead of providing separate methods for each supported property we rely
  # on Ruby's #method_missing to do most of the work.
  class ReportItem
    include Cleanup

    attr_accessor :xml

    # Accepts an XML node from Nokogiri::XML.
    def initialize(xml_node)
      @xml = xml_node
    end

    # List of supported tags. They can be attributes, simple descendans or
    # collections.
    def supported_tags
      [
        # attributes
        # :color

        # simple tags
        :name, :module_name, :severity, :type, :impact, :description,
        :detailed_information, :recommendation, :cwe,

        # tags that correspond to Evidence
        :details, :affects, :parameter, :aop_source_file, :aop_source_line,
        :aop_additional, :is_false_positive,


        # nested tags
        :request, :response,
        :cvss_descriptor, :cvss_score,
        :cvss3_descriptor, :cvss3_score, :cvss3_tempscore, :cvss3_envscore,

        # multiple tags
        :cve_list, :references
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
    # attribute, simple descendent or collection that it maps to in the XML
    # tree.
    def method_missing(method, *args)

      # We could remove this check and return nil for any non-recognized tag.
      # The problem would be that it would make tricky to debug problems with
      # typos. For instance: <>.potr would return nil instead of raising an
      # exception
      unless supported_tags.include?(method)
        super
        return
      end

      # Any fields where a simple .camelcase() won't work we need to translate,
      # this includes acronyms (e.g. :cwe would become 'Cwe') and simple nested
      # tags.
      translations_table = {
                    cwe: 'CWE',
        aop_source_file: 'AOPSourceFile',
        aop_source_line: 'AOPSourceLine',
         aop_additional: 'AOPAdditional',
                request: 'TechnicalDetails/Request',
               response: 'TechnicalDetails/Response',
        cvss_descriptor: 'CVSS/Descriptor',
             cvss_score: 'CVSS/Score',
       cvss3_descriptor: 'CVSS3/Descriptor',
            cvss3_score: 'CVSS3/Score',
        cvss3_tempscore: 'CVSS3/TempScore',
         cvss3_envscore: 'CVSS3/EnvScore'
      }
      method_name = translations_table.fetch(method, method.to_s.camelcase)
      # first we try the attributes:
      # return @xml.attributes[method_name].value if @xml.attributes.key?(method_name)


      # There is a ./References tag, but we want to short-circuit that one to
      # do custom processing.
      return references_list() if method == :references

      # then we try the children tags
      tag = xml.at_xpath("./#{method_name}")
      if tag && !tag.text.blank?
        if tags_with_html_content.include?(method)
          return cleanup_html(tag.text)
        elsif tags_with_commas.include?(method)
          return cleanup_decimals(tag.text)
        else
          return tag.text
        end
      else
        'n/a'
      end

      return 'unimplemented'   if method == :cve_list

      # nothing found
      return nil
    end

    private

    def references_list
      references = ''
      xml.xpath('./References/Reference').each do |xml_reference|
        references << xml_reference.at_xpath('./Database').text()
        references << "\n"
        references << xml_reference.at_xpath('./URL').text()
        references << "\n\n"
      end
      references
    end
  end
end
