module Dradis::Plugins::Acunetix
  module Standard
    def self.meta
      package = Dradis::Plugins::Acunetix
      {
        name: package::Engine::plugin_name,
        description: 'Upload Standard Acunetix output file (.xml)',
        version: package.version
      }
    end

    class Importer < Dradis::Plugins::Upload::Importer
      attr_accessor :scan_node, :xml

      def self.templates
        { evidence: 'evidence', issue: 'report_item' }
      end

      def initialize(args = {})
        args[:plugin] = Dradis::Plugins::Acunetix
        super(args)
      end

      # The framework will call this function if the user selects this plugin from
      # the dropdown list and uploads a file.
      # @returns true if the operation was successful, false otherwise
      def import(params = {})
        file_content = File.read(params.fetch(:file))

        logger.info {'Parsing Standard Acunetix output file...'}
        @xml = Nokogiri::XML(file_content)
        logger.info{'Done.'}

        unless xml.xpath('/ScanGroup/Scan').present?
          error = 'No scan results were detected in the uploaded file (/ScanGroup/Scan). Ensure you uploaded an Acunetix XML report.'
          logger.fatal{ error }
          content_service.create_note text: error
          return false
        end

        process_standard

        logger.info { 'Standard Acunetix file successfully imported' }
        true
      end

      private

      def process_standard
        xml.xpath('/ScanGroup/Scan').each do |xml_scan|
          process_scan(xml_scan)
        end
      end

      def process_scan(xml_scan)
        url = xml_scan.at_xpath('./StartURL').text()
        start_url = URI::parse(url).host || url # urls wo/ protocol returned nil

        self.scan_node = content_service.create_node(label: start_url, type: :host)
        logger.info{ "\tScan start URL: #{start_url}" }

        # Define Node properties
        if scan_node.respond_to?(:properties)
          scan_node.set_property(:short_name, xml_scan.at_xpath('./ShortName').text() )
          scan_node.set_property(:start_url, start_url)
          scan_node.set_property(:start_time, xml_scan.at_xpath('./StartTime').text() )
          scan_node.set_property(:finish_time, xml_scan.at_xpath('./FinishTime').text() )
          scan_node.set_property(:scan_time, xml_scan.at_xpath('./ScanTime').text() )
          scan_node.set_property(:aborted, xml_scan.at_xpath('./Aborted').text() )
          scan_node.set_property(:responsive, xml_scan.at_xpath('./Responsive').text() )
          scan_node.set_property(:banner, xml_scan.at_xpath('./Banner').text() )
          scan_node.set_property(:os, xml_scan.at_xpath('./Os').text() )
          scan_node.set_property(:web_server, xml_scan.at_xpath('./WebServer').text() )
          scan_node.set_property(:technologies, xml_scan.at_xpath('./Technologies').text() )
          scan_node.save
        end

        scan_note = mapping_service.apply_mapping(source: 'scan', data: xml_scan)
        content_service.create_note text: scan_note, node: scan_node

        xml_scan.xpath('./ReportItems/ReportItem').each do |xml_report_item|
          process_report_item(xml_report_item)
        end
      end

      def process_report_item(xml_report_item)
        plugin_id = "%s/%s" % [
                                xml_report_item.at_xpath('./ModuleName').text(),
                                xml_report_item.at_xpath('./Name').text()
                              ]
        logger.info { "\t\t => Creating new issue (plugin_id: #{plugin_id})" }

        issue_text = mapping_service.apply_mapping(source: 'report_item', data: xml_report_item)
        issue = content_service.create_issue(text: issue_text, id: plugin_id)

        logger.info { "\t\t => Creating new evidence" }
        evidence_content = mapping_service.apply_mapping(source: 'evidence', data: xml_report_item)
        content_service.create_evidence(issue: issue, node: scan_node, content: evidence_content)
      end
    end
  end
end
