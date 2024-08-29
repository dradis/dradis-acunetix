require 'spec_helper'
require 'ostruct'

module Dradis::Plugins
  describe Acunetix::Acunetix360::Importer do
    before(:each) do
      stub_mapping_service
      stub_content_service

      @importer = described_class.new(content_service: @content_service)
    end

    let(:example_xml) { 'spec/fixtures/files/acunetix360.xml' }

    def run_import!
      @importer.import(file: example_xml)
    end

    it 'creates nodes as needed' do
      expect(@content_service).to receive(:create_node).with(hash_including label: 'http://aspnet.testsparker.com/', type: :host).once

      run_import!
    end

    it 'creates issues from vulnerability elements' do
      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('Blind SQL Injection')
        expect(args[:id]).to eq('ConfirmedBlindSqlInjection')
      end.once

      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('Cross-site Scripting')
        expect(args[:id]).to eq('Xss')
      end.once

      run_import!
    end

    it 'creates evidence from vulnerability elements' do
      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('25053.3534')
        expect(args[:issue].id).to eq('ConfirmedBlindSqlInjection')
        expect(args[:node].label).to eq('http://aspnet.testsparker.com/')
      end.once

      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('160.6656')
        expect(args[:issue].id).to eq('Xss')
        expect(args[:node].label).to eq('http://aspnet.testsparker.com/')
      end

      run_import!
    end
  end
end
