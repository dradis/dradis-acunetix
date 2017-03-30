module Dradis::Plugins::Acunetix
  class Importer < Dradis::Plugins::Upload::Importer

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    #
    # @return true if the operation was successful, false otherwise
    def import(params={})
      file_content    = File.read( params.fetch(:file) )

      logger.info { 'Parsing Acunetix output file...'}
      @doc = Nokogiri::XML( file_content )
      logger.info { 'Done.'}

      if scan_results.any?
        scan_results.each { |scan_xml| process_scan(scan_xml) }
        true
      else
        log_error
        false
      end
    end # /import


    private
    attr_accessor :scan_node

    def process_scan(scan_xml)
      start_url = URI::parse(scan_xml.at_xpath('./StartURL').text()).host

      @scan_node = content_service.create_node(label: start_url, type: :host)
      logger.info{ "\tScan start URL: #{start_url}" }

      scan_note = template_service.process_template(template: 'scan', data: scan_xml)
      content_service.create_note text: scan_note, node: @scan_node

      scan_xml.xpath('./ReportItems/ReportItem').each do |xml_report_item|
        process_report_item(xml_report_item)
      end
    end

    def process_report_item(xml_report_item)
      plugin_id = "%s/%s" % [
                              xml_report_item.at_xpath('./ModuleName').text(),
                              xml_report_item.at_xpath('./Name').text()
                            ]
      logger.info{ "\t\t => Creating new issue (plugin_id: #{plugin_id})" }

      issue_text = template_service.process_template(template: 'report_item', data: xml_report_item)
      issue = content_service.create_issue(text: issue_text, id: plugin_id)

      logger.info{ "\t\t => Creating new evidence" }

      evidence_content = template_service.process_template(
        template: 'evidence',
        data: xml_report_item
      )

      content_service.create_evidence(
        issue: issue,
        node: @scan_node,
        content: evidence_content
      )
    end

    def scan_results
      @_scan_results ||= @doc.xpath('/ScanGroup/Scan')
    end

    def log_error
      error = "No scan results were detected in the uploaded file "\
              "(/ScanGroup/Scan). Ensure you uploaded an Acunetix XML report."
      logger.fatal { error }
      content_service.create_note text: error
    end

  end
end
