module Dradis::Plugins::Acunetix
  module Acunetix360
    def self.meta
      package = Dradis::Plugins::Acunetix
      {
        name: package::Engine::plugin_name,
        description: 'Upload Acunetix360 output file (.xml)',
        version: package.version
      }
    end

    class Importer < Dradis::Plugins::Upload::Importer
      attr_accessor :scan_node, :xml

      def self.templates
        { evidence: 'evidence_360', issue: 'vulnerability_360' }
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

        logger.info { 'Parsing Acunetix360 output file...' }
        @xml = Nokogiri::XML( file_content )
        logger.info { 'Done.' }

        unless xml.xpath('//acunetix-360').present?
          error = 'No Acunetix360 results were detected in the uploaded file. Ensure you uploaded an Acunetix360 XML report.'
          logger.fatal { error }
          content_service.create_note text: error
          return false
        end

        process_acunetix360

        logger.info { 'Acunetix360 file successfully imported' }
        true
      end

      private

      def process_acunetix360
        process_target_node
        process_acunetix360_vulnerabilities
      end

      def process_target_node
        target_xml = xml.at_xpath('//acunetix-360/target')
        @scan_node = content_service.create_node(
          label: target_xml.at_xpath('url').text,
          type: :host
        )

        logger.info { "Creating target node: #{scan_node.label}" }

        if scan_node.respond_to?(:properties)
          scan_node.set_property(:scan_id, target_xml.at_xpath('scan-id').text)
          scan_node.set_property(:initiated, target_xml.at_xpath('initiated').text)
          scan_node.set_property(:duration, target_xml.at_xpath('duration').text)
        end
      end

      def process_acunetix360_vulnerabilities
        logger.info { 'Creating issues from Acunetix360 vulnerabilities.' }

        xml.xpath('//acunetix-360/vulnerabilities/vulnerability').each do |vuln_xml|
          issue_text = mapping_service.apply_mapping(
            source: 'vulnerability_360',
            data: vuln_xml
          )

          type = vuln_xml.at_xpath('type').text

          logger.info { "\t\t => Creating new issue: #{type}" }
          issue = content_service.create_issue(text: issue_text, id: type)

          evidence_text = mapping_service.apply_mapping(
            source: 'evidence_360',
            data: vuln_xml
          )

          logger.info { "\t\t => Creating new evidence" }
          content_service.create_evidence(issue: issue, node: scan_node, content: evidence_text)
        end
      end
    end
  end
end
