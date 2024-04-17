module Dradis::Plugins::Acunetix
  module Mapping
    DEFAULT_MAPPING = {
      evidence_360: {
        'HTTP Request' => '{{ acunetix[evidence_360.http_request] }}',
        'HTTP Response' => '{{ acunetix[evidence_360.http_response] }}'
      },
      evidence: {
        'Details' => '{{ acunetix[evidence.details] }}',
        'Affects' => "|_. Location |_. Parameter |\n| {{ acunetix[evidence.affects] }} | {{ acunetix[evidence.parameter] }} |",
        'AOP' => "|_. File |_. Line |_. Additional |\n| {{ acunetix[evidence.aop_source_file] }} | {{ acunetix[evidence.aop_source_line] }} | {{ acunetix[evidence.aop_additional] }} |",
        'FalsePositive' => '{{ acunetix[evidence.is_false_positive] }}'
      },
      report_item: {
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
      scan: {
        'Title' => 'Acunetix scanner notes ({{ acunetix[scan.start_time] }})',
        'ScanName' => '{{ acunetix[scan.name] }}',
        'StartURL' => '{{ acunetix[scan.start_url] }}',
        'TimeAndFlags' => "|_. Start |_. Finish |_. Total |_. Aborted |_. Responsive |\n| {{ acunetix[scan.start_time] }} | {{ acunetix[scan.finish_time] }} | {{ acunetix[scan.scan_time] }} | {{ acunetix[scan.aborted] }} | {{ acunetix[scan.responsive] }} |",
        'Fingerprint' => "|_. Banner |_. OS |_. Web server |_. Technologies |\n| {{ acunetix[scan.banner] }} | {{ acunetix[scan.os] }} | {{ acunetix[scan.web_server] }} | {{ acunetix[scan.technologies] }} |"
      },
      vulnerability_360: {
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
    }.freeze

    SOURCE_FIELDS = {
      evidence_360: [
        'evidence_360.http_request',
        'evidence_360.http_request_method',
        'evidence_360.http_response',
        'evidence_360.http_response_status_code',
        'evidence_360.http_response_duration'
      ],
      evidence: [
        'evidence.details',
        'evidence.affects',
        'evidence.parameter',
        'evidence.aop_source_file',
        'evidence.aop_source_line',
        'evidence.aop_additional',
        'evidence.is_false_positive',
        'evidence.request',
        'evidence.response'
      ],
      report_item: [
        'report_item.name',
        'report_item.module_name',
        'report_item.severity',
        'report_item.type',
        'report_item.impact',
        'report_item.description',
        'report_item.detailed_information',
        'report_item.recommendation',
        'report_item.request',
        'report_item.response',
        'report_item.cvss_descriptor',
        'report_item.cvss_score',
        'report_item.cvss3_descriptor',
        'report_item.cvss3_score',
        'report_item.cvss3_tempscore',
        'report_item.cvss3_envscore',
        'report_item.cve_list',
        'report_item.references'
      ],
      scan: [
        'scan.name',
        'scan.short_name',
        'scan.start_url',
        'scan.start_time',
        'scan.finish_time',
        'scan.scan_time',
        'scan.aborted',
        'scan.responsive',
        'scan.banner',
        'scan.os',
        'scan.web_server',
        'scan.technologies'
      ],
      vulnerability_360: [
        'vulnerability_360.name',
        'vulnerability_360.type',
        'vulnerability_360.url',
        'vulnerability_360.description',
        'vulnerability_360.impact',
        'vulnerability_360.remedial_actions',
        'vulnerability_360.exploitation_skills',
        'vulnerability_360.remedial_procedure',
        'vulnerability_360.remedy_references',
        'vulnerability_360.external_references',
        'vulnerability_360.severity',
        'vulnerability_360.certainty',
        'vulnerability_360.confirmed',
        'vulnerability_360.state',
        'vulnerability_360.owasp',
        'vulnerability_360.wasc',
        'vulnerability_360.cwe',
        'vulnerability_360.capec',
        'vulnerability_360.pci32',
        'vulnerability_360.hipaa',
        'vulnerability_360.owasppc',
        'vulnerability_360.iso27001',
        'vulnerability_360.cvss_vector',
        'vulnerability_360.cvss_base',
        'vulnerability_360.cvss_temporal',
        'vulnerability_360.cvss_environmental',
        'vulnerability_360.cvss31_vector',
        'vulnerability_360.cvss31_base',
        'vulnerability_360.cvss31_temporal',
        'vulnerability_360.cvss31_environmental'
      ]
    }.freeze
  end
end
