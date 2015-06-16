module Dradis::Plugins::Acunetix
  class Importer < Dradis::Plugins::Upload::Importer

    NO_SCAN_RESULTS_ERROR_MESSAGE = \
      "No scan results were detected in the uploaded file (/ScanGroup/Scan). "\
      "Ensure you uploaded an Acunetix XML report."

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    #
    # @returns true if the operation was successful, false otherwise
    def import(params={})
      file_content = File.read(params.fetch(:file))

      logger.info{'Parsing Acunetix output file...'}
      @doc = Nokogiri::XML( file_content )
      logger.info{'Done.'}

      if @doc.xpath('/ScanGroup/Scan').empty?
        logger.fatal{ NO_SCAN_RESULTS_ERROR_MESSAGE }
        content_service.create_note text: NO_SCAN_RESULTS_ERROR_MESSAGE
        return false
      end

      @doc.xpath('/ScanGroup/Scan').each do |xml_scan|
        scan = ::Acunetix::Scan.new(xml_scan)
        process_scan(scan)
      end

      true
    end # /import


    private
    attr_accessor :scan_node

    def process_scan(scan)
      self.scan_node = scan.to_node(content_service)
      scan_node.save!

      logger.info{ "\tScan start URL: #{scan.start_url_host}" }

      scan_note = template_service.process_template(
        template: 'scan', data: scan.xml
      )

      content_service.create_note text: scan_note, node: scan_node

      scan.report_items.each do |xml_report_item|
        process_report_item(xml_report_item)
      end
    end

    def process_report_item(xml_report_item)
      plugin_id = xml_report_item.at_xpath('./ModuleName').text()
      logger.info{ "\t\t => Creating new issue (plugin_id: #{plugin_id})" }

      issue_text = template_service.process_template(
        template: 'report_item', data: xml_report_item
      )
      issue = content_service.create_issue(text: issue_text, id: plugin_id)

      logger.info{ "\t\t => Creating new evidence" }
      evidence_content = template_service.process_template(
        template: 'evidence', data: xml_report_item
      )
      content_service.create_evidence(
        issue: issue, node: scan_node, content: evidence_content
      )
    end
  end
end
