module Dradis::Plugins::Acunetix::Formats
  module Acunetix360

    private

    def process_acunetix360
      process_target_node
      process_acunetix360_vulnerabilities
    end

    def process_target_node
      target_xml = xml.at_xpath('//acunetix-360/target')
      scan_node = content_service.create_node(
        label: target_xml.at_xpath('url').text,
        type: :host
      )

      logger.info { "Creating target node: #{target_node.label}" }

      if scan_node.respond_to?(:properties)
        scan_node.set_property(:scan_id, target_xml.at_xpath('scan-id').text)
        scan_node.set_property(:initiated, target_xml.at_xpath('initiated').text)
        scan_node.set_property(:duration, target_xml.at_xpath('duration').text)
      end
    end

    def process_acunetix360_vulnerabilities
      logger.info { "Creating issues from Acunetix360 vulnerabilities." }

      xml.xpath('//acunetix-360/vulnerabilities/vulnerability').each do |vuln|
        issue_text = template_service.process_template(
          template: 'acunetix360_vulnerability',
          data: vuln
        )

        lookup_id = vuln.xpath('')
        content_service.create_issue(text: issue_text, id: lookup_id)
      end
    end
  end
end
