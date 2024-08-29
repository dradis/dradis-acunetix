require 'rubygems'
require 'bundler/setup'
require 'nokogiri'

require 'combustion'

Dir[Rails.root.join('spec/support/*.rb')].each { |f| require f }

Combustion.initialize!

RSpec.configure do |config|
  config.include SpecMacros
end

class StubbedMappingService
  def apply_mapping(args)
    processor = Dradis::Plugins::Acunetix::FieldProcessor.new(data: args[:data])

    Dradis::Plugins::Acunetix::Mapping::SOURCE_FIELDS[args[:source].to_sym].map do |field|
      processor.value(field: field)
    end.join("\n")
  end
end
