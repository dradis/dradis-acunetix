require 'spec_helper'
require 'ostruct'

describe 'Acunetix upload plugin' do
  before(:each) do
    # Stub template service
    templates_dir = File.expand_path('../../templates', __FILE__)
    expect_any_instance_of(Dradis::Plugins::TemplateService)
    .to receive(:default_templates_dir).and_return(templates_dir)

    # Init services
    plugin = Dradis::Plugins::Acunetix

    @content_service = Dradis::Plugins::ContentService.new(plugin: plugin)
    template_service = Dradis::Plugins::TemplateService.new(plugin: plugin)

    @importer = plugin::Importer.new(
      content_service: @content_service,
      template_service: template_service
    )

    # Stub dradis-plugins methods
    #
    # They return their argument hashes as objects mimicking
    # Nodes, Issues, etc
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

  it "creates nodes, issues, notes and an evidences as needed" do

    expect(@content_service).to receive(:create_node).with(hash_including label: "testphp.vulnweb.com", type: :host).once
    expect(@content_service).to receive(:create_note) do |args|
      expect(args[:text]).to include("#[Title]#\nAcunetix scanner notes (7/10/2014, 11:56:03)")
      expect(args[:node].label).to eq("testphp.vulnweb.com")
    end.once

    expect(@content_service).to receive(:create_issue) do |args|
      expect(args[:text]).to include("#[Title]#\nHTML form without CSRF protection")
      expect(args[:id]).to eq("Crawler")
      OpenStruct.new(args)
    end.once

    expect(@content_service).to receive(:create_issue) do |args|
      expect(args[:text]).to include("#[Title]#\nClickjacking: X-Frame-Options header missing")
      expect(args[:id]).to eq("Scripting (Clickjacking_X_Frame_Options.script)")
      OpenStruct.new(args)
    end.once

    expect(@content_service).to receive(:create_evidence) do |args|
      expect(args[:content]).to include("/")
      expect(args[:issue].id).to eq("Crawler")
      expect(args[:node].label).to eq("testphp.vulnweb.com")
    end.once

    expect(@content_service).to receive(:create_evidence) do |args|
      expect(args[:content]).to include("Web Server")
      expect(args[:issue].id).to eq("Scripting (Clickjacking_X_Frame_Options.script)")
      expect(args[:node].label).to eq("testphp.vulnweb.com")
    end.once

    @importer.import(file: 'spec/fixtures/files/simple.acunetix.xml')
  end

  # Regression test for github.com/dradis/dradis-nexpose/issues/1
  describe "Source HTML parsing" do
    pending "identifies code/pre blocks and replaces them with the Textile equivalent"
  end
end
