module SpecMacros
  extend ActiveSupport::Concern

  def stub_content_service
    @content_service = Dradis::Plugins::ContentService::Base.new(plugin: Dradis::Plugins::Acunetix)

    # Stub dradis-plugins methods
    # They return their argument hashes as objects mimicking
    # nodes, issues, etc
    allow(@content_service).to receive(:create_node) do |args|
      OpenStruct.new(args)
    end
    allow(@content_service).to receive(:create_note) do |args|
      OpenStruct.new(args)
    end
    allow(@content_service).to receive(:create_issue) do |args|
      OpenStruct.new(args)
    end
    allow(@content_service).to receive(:create_evidence) do |args|
      OpenStruct.new(args)
    end
  end
end
