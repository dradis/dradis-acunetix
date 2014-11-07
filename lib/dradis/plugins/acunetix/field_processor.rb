module Dradis::Plugins::Acunetix
  class FieldProcessor < Dradis::Plugins::Upload::FieldProcessor

    def post_initialize(args={})
      # @acunetix_object = (data.name == 'Scan') ? ::Nessus::Host.new(data) : ::Nessus::ReportItem.new(data)
    end

    def value(args={})
      field = args[:field]

      # fields in the template are of the form <foo>.<field>, where <foo>
      # is common across all fields for a given template (and meaningless).
      _, name = field.split('.')

      tag_name = if name == 'start_url'
                  'StartURL'
                else
                  name.camelcase
                end

      if tag = data.at_xpath("./#{tag_name}")
        tag.text()
      else
        'n/a'
      end
    end
  end

end
