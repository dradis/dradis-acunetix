module Dradis::Plugins::Acunetix
  module Mapping
    def default_mapping
      {
        'evidence_360' => {
          'HTTP Request' => '{{ acunetix[evidence_360.http_request] }}', 
          'HTTP Response' => '{{ acunetix[evidence_360.http_response] }}'
        },
        'evidence' => {
          'Details' => '{{ acunetix[evidence.details] }}', 
          'Affects' => "|_. Location |_. Parameter |\n
                        | {{ acunetix[evidence.affects] }} | {{ acunetix[evidence.parameter] }} |",
          'AOP' => "|_. File |_. Line |_. Additional |\n
                    | {{ acunetix[evidence.aop_source_file] }} | {{ acunetix[evidence.aop_source_line] }} | {{ acunetix[evidence.aop_additional] }} |",
          'FalsePositive' => '{{ acunetix[evidence.is_false_positive] }}'
        },
        'report_item' => {
          'Title' => '{{ acunetix[report_item.name] }}',
          'Severity' => '{{ acunetix[report_item.severity] }}',
          'Type' => '{{ acunetix[report_item.type] }}',
          'Impact' => '{{ acunetix[report_item.impact] }}',
          'Description' => '{{ acunetix[report_item.description] }}',
          'DetailedInformation' => '{{ acunetix[report_item.detailed_information] }}',
          'Recommendation' => '{{ acunetix[report_item.recommendation] }}',
          'CVSSVector' => '{{ acunetix[report_item.cvss_descriptor] }}',
          'CVSSScore' => '{{ acunetix[report_item.cvss_score] }}',
          'CVSS3Vector' => '{{ acunetix[report_item.cvss3_descriptor] }}',
          'CVSS3Score' => '{{ acunetix[report_item.cvss3_score] }}',
          'CVSS3TempScore' => '{{ acunetix[report_item.cvss3_tempscore] }}',
          'CVSS3EnvScore' => '{{ acunetix[report_item.cvss3_envscore] }}',
          'CVEList' => '{{ acunetix[report_item.cve_list] }}',
          'References' => '{{ acunetix[report_item.references] }}'
        },
        'scan' => {
          'Title' => 'Acunetix scanner notes ({{ acunetix[scan.start_time] }})',
          'ScanName' => '{{ acunetix[scan.name] }}',
          'StartURL' => '{{ acunetix[scan.start_url] }}',
          'TimeAndFlags' => "|_. Start |_. Finish |_. Total |_. Aborted |_. Responsive |\n
                            | {{ acunetix[scan.start_time] }} | {{ acunetix[scan.finish_time] }} | {{ acunetix[scan.scan_time] }} | {{ acunetix[scan.aborted] }} | {{ acunetix[scan.responsive] }} |",
          'Fingerprint' => "|_. Banner |_. OS |_. Web server |_. Technologies |\n
                            | {{ acunetix[scan.banner] }} | {{ acunetix[scan.os] }} | {{ acunetix[scan.web_server] }} | {{ acunetix[scan.technologies] }} |"
        },
        'vulnerability_360' => {
          'Title' => '{{ acunetix[vulnerability_360.name] }}',
          'Type' => '{{ acunetix[vulnerability_360.type] }}',
          'URL' => '{{ acunetix[vulnerability_360.url] }}',
          'Severity' => '{{ acunetix[vulnerability_360.severity] }}',
          'Description' => '{{ acunetix[vulnerability_360.description] }}',
          'Impact' => '{{ acunetix[vulnerability_360.impact] }}',
          'Certainty' => '{{ acunetix[vulnerability_360.certainty] }}',
          'Confirmed' => '{{ acunetix[vulnerability_360.confirmed] }}',
          'State' => '{{ acunetix[vulnerability_360.state] }}',
          'OWASP' => '{{ acunetix[vulnerability_360.owasp] }}',
          'WASC' => '{{ acunetix[vulnerability_360.wasc] }}',
          'CWE' => '{{ acunetix[vulnerability_360.cwe] }}',
          'CAPEC' => '{{ acunetix[vulnerability_360.capec] }}',
          'PCI32' => '{{ acunetix[vulnerability_360.pci32] }}',
          'HIPAA' => '{{ acunetix[vulnerability_360.hipaa] }}',
          'OWASPPC' => '{{ acunetix[vulnerability_360.owasppc] }}',
          'ISO27001' => '{{ acunetix[vulnerability_360.iso27001] }}',
          'CVSSVector' => '{{ acunetix[vulnerability_360.cvss_vector] }}',
          'CVSSBase' => '{{ acunetix[vulnerability_360.cvss_base] }}',
          'CVSSTemporal' => '{{ acunetix[vulnerability_360.cvss_temporal] }}',
          'CVSSEnvironmental' => '{{ acunetix[vulnerability_360.cvss_environmental] }}',
          'CVSS3Vector' => '{{ acunetix[vulnerability_360.cvss31_vector] }}',
          'CVSS3Base' => '{{ acunetix[vulnerability_360.cvss31_base] }}',
          'CVSS3Temporal' => '{{ acunetix[vulnerability_360.cvss31_temporal] }}',
          'CVSS3Environmental' => '{{ acunetix[vulnerability_360.cvss31_environmental] }}'
        }
      }
    end
  end
end
