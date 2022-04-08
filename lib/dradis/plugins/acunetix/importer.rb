require 'dradis/plugins/acunetix/formats/standard'
require 'dradis/plugins/acunetix/formats/acunetix360'

module Dradis::Plugins::Acunetix
  class Importer < Dradis::Plugins::Upload::Importer
    include Dradis::Plugins::Acunetix::Formats::Standard
    include Dradis::Plugins::Acunetix::Formats::Acunetix360

    attr_accessor :scan_node, :xml

    def self.templates
      { evidence: 'evidence', issue: 'report_item' }
    end

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    # @returns true if the operation was successful, false otherwise
    def import(params={})
      file_content    = File.read( params.fetch(:file) )

      logger.info{'Parsing Acunetix output file...'}
      @xml = Nokogiri::XML( file_content )
      logger.info{'Done.'}

      if xml.xpath('/ScanGroup/Scan').present?
        logger.info { 'Standard Acunetix import detected.' }
        process_standard

        return true
      elsif xml.xpath('//acunetix-360').present?
        logger.info { 'Acunetix360 import detected.' }
        process_acunetix360

        return true
      else
        error = "No scan results were detected in the uploaded file (/ScanGroup/Scan). Ensure you uploaded an Acunetix XML report."
        logger.fatal{ error }
        content_service.create_note text: error
        return false
      end
    end # /import
  end
end
