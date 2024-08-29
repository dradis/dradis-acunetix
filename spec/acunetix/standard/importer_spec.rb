require 'spec_helper'
require 'ostruct'

module Dradis::Plugins

  describe Acunetix::Standard::Importer do

    before(:each) do
      stub_mapping_service
      stub_content_service

      @importer = described_class.new(content_service: @content_service)
    end

    def run_import!
      @importer.import(file: 'spec/fixtures/files/simple.acunetix.xml')
    end

    it "creates nodes as needed" do
      expect(@content_service).to receive(:create_node).with(hash_including label: "testphp.vulnweb.com", type: :host).once

      run_import!
    end

    it 'creates notes as needed' do
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:text]).to include('Scan Thread 1')
        expect(args[:node].label).to eq('testphp.vulnweb.com')
      end.once

      run_import!
    end

    it "creates issues from report_item elements" do
      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('HTML form without CSRF protection')
        expect(args[:id]).to eq("Crawler/HTML form without CSRF protection")
      end.once

      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('Clickjacking: X-Frame-Options header missing')
        expect(args[:id]).to eq("Scripting (Clickjacking_X_Frame_Options.script)/Clickjacking: X-Frame-Options header missing")
      end.once

      run_import!
    end

    it "creates evidence from report_item elements" do
      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('Form name:')
        expect(args[:issue].id).to eq("Crawler/HTML form without CSRF protection")
        expect(args[:node].label).to eq("testphp.vulnweb.com")
      end.once

      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include("Web Server")
        expect(args[:issue].id).to eq("Scripting (Clickjacking_X_Frame_Options.script)/Clickjacking: X-Frame-Options header missing")
        expect(args[:node].label).to eq("testphp.vulnweb.com")
      end

      run_import!
    end
  end
end
