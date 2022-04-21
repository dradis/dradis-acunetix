require 'spec_helper'
require 'ostruct'
require 'byebug'
module Dradis::Plugins
  describe 'Acunetix upload plugin' do
    before(:each) do
      templates_dir = File.expand_path('../../templates', __FILE__)
      expect_any_instance_of(Dradis::Plugins::TemplateService)
      .to receive(:default_templates_dir).and_return(templates_dir)

      plugin = Dradis::Plugins::Acunetix

      @content_service = Dradis::Plugins::ContentService::Base.new(plugin: plugin)

      allow(@content_service).to receive(:create_note) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_node) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_issue) do |args|
        OpenStruct.new(args)
      end
      allow(@content_service).to receive(:create_evidence) do |args|
        OpenStruct.new(args)
      end

      @importer = plugin::Importer.new(
        content_service: @content_service
      )
    end

    describe "Source HTML parsing" do
      it "parses links in <external-references> tag" do

        expect(@content_service).to receive(:create_issue) do |args|
          expect(args[:text]).to include('"Link 1":https://link1.com')
          expect(args[:text]).to include('"Link 2":https://link2.com')
          OpenStruct.new(args)
        end.once

        @importer.import(file: 'spec/fixtures/files/acunetix_360.xml')
      end
    end
  end
end
