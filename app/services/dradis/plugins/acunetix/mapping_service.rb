module Dradis::Plugins::Acunetix
  class MappingService
    def default_mapping
      {
        'evidence_360' => {
          'HTTP Request' => '{{ evidence_360.http_request }}', 
          'HTTP Response' => '{{ evidence_360.http_response }}'
        },
        'evidence' => {
          'Details' => '{{ evidence_360.http_request }}', 
          'Affects' => "|_. Location |_. Parameter |\n
                        | {{ evidence.affects }} | {{ evidence.parameter }} |",
          'AOP' => "|_. File |_. Line |_. Additional |\n
                    | {{ evidence.aop_source_file }} | {{ evidence.aop_source_line }} | {{ evidence.aop_additional }} |",
          'FalsePositive' => '{{ evidence.is_false_positive }}'
        },
        'report_item' => {
          'Title' => '{{ report_item.name }}',
          'Severity' => '{{ report_item.severity }}',
          'Type' => '{{ report_item.type }}',
          'Impact' => '{{ report_item.impact }}',
          'Description' => '{{ report_item.description }}',
          'DetailedInformation' => '{{ report_item.detailed_information }}',
          'Recommendation' => '{{ report_item.recommendation }}',
          'CVSSVector' => '{{ report_item.cvss_descriptor }}',
          'CVSSScore' => '{{ report_item.cvss_score }}',
          'CVSS3Vector' => '{{ report_item.cvss3_descriptor }}',
          'CVSS3Score' => '{{ report_item.cvss3_score }}',
          'CVSS3TempScore' => '{{ report_item.cvss3_tempscore }}',
          'CVSS3EnvScore' => '{{ report_item.cvss3_envscore }}',
          'CVEList' => '{{ report_item.cve_list }}',
          'References' => '{{ report_item.references }}'
        },
        'scan' => {
          'Title' => 'Acunetix scanner notes ({{ scan.start_time }})',
          'ScanName' => '{{ scan.name }}',
          'StartURL' => '{{ scan.start_url }}',
          'TimeAndFlags' => "|_. Start |_. Finish |_. Total |_. Aborted |_. Responsive |\n
                            | {{ scan.start_time }} | {{ scan.finish_time }} | {{ scan.scan_time }} | {{ scan.aborted }} | {{ scan.responsive }} |",
          'Fingerprint' => "|_. Banner |_. OS |_. Web server |_. Technologies |\n
                            | {{ scan.banner }} | {{ scan.os }} | {{ scan.web_server }} | {{ scan.technologies }} |"
        },
        'vulnerability_360' => {
          'Title' => '{{ vulnerability_360.name }}',
          'Type' => '{{ vulnerability_360.type }}',
          'URL' => '{{ vulnerability_360.url }}',
          'Severity' => '{{ vulnerability_360.severity }}',
          'Description' => '{{ vulnerability_360.description }}',
          'Impact' => '{{ vulnerability_360.impact }}',
          'Certainty' => '{{ vulnerability_360.certainty }}',
          'Confirmed' => '{{ vulnerability_360.confirmed }}',
          'State' => '{{ vulnerability_360.state }}',
          'OWASP' => '{{ vulnerability_360.owasp }}',
          'WASC' => '{{ vulnerability_360.wasc }}',
          'CWE' => '{{ vulnerability_360.cwe }}',
          'CAPEC' => '{{ vulnerability_360.capec }}',
          'PCI32' => '{{ vulnerability_360.pci32 }}',
          'HIPAA' => '{{ vulnerability_360.hipaa }}',
          'OWASPPC' => '{{ vulnerability_360.owasppc }}',
          'ISO27001' => '{{ vulnerability_360.iso27001 }}',
          'CVSSVector' => '{{ vulnerability_360.cvss_vector }}',
          'CVSSBase' => '{{ vulnerability_360.cvss_base }}',
          'CVSSTemporal' => '{{ vulnerability_360.cvss_temporal }}',
          'CVSSEnvironmental' => '{{ vulnerability_360.cvss_environmental }}',
          'CVSS3Vector' => '{{ vulnerability_360.cvss31_vector }}',
          'CVSS3Base' => '{{ vulnerability_360.cvss31_base }}',
          'CVSS3Temporal' => '{{ vulnerability_360.cvss31_temporal }}',
          'CVSS3Environmental' => '{{ vulnerability_360.cvss31_environmental }}'
        }
      }
    end
  end
end
