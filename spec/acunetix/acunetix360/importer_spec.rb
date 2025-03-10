# To run, execute from Dradis main app folder:
# bin/rspec [dradis-acunetix path]/spec/acunetix/acunetix360/importer_spec.rb
require 'rails_helper'
require 'ostruct'
require File.expand_path('../../../../../dradis-plugins/spec/support/spec_macros.rb', __FILE__)

include Dradis::Plugins::SpecMacros

module Dradis::Plugins
  describe Acunetix::Acunetix360::Importer do
    before do
      @fixtures_dir = File.expand_path('../../../fixtures/files/', __FILE__)
    end

    before(:each) do
      stub_content_service

      @importer = described_class.new(content_service: @content_service)
    end

    def run_import!
      @importer.import(file: @fixtures_dir + '/acunetix360.xml')
    end

    it 'creates nodes as needed' do
      expect(@content_service).to receive(:create_node).with(hash_including label: 'http://aspnet.testsparker.com/', type: :host).once

      run_import!
    end

    it 'creates issues from vulnerability elements' do
      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include("#[Title]#\nBlind SQL Injection")
        expect(args[:id]).to eq('ConfirmedBlindSqlInjection')
      end.once

      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include("#[Title]#\nCross-site Scripting")
        expect(args[:id]).to eq('Xss')
      end.once

      run_import!
    end

    it 'creates evidence from vulnerability elements' do
      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('POST /blog/%27))%20WAITFOR%20DELAY%20%270%3a0%3a25%27')
        expect(args[:issue].id).to eq('ConfirmedBlindSqlInjection')
        expect(args[:node].label).to eq('http://aspnet.testsparker.com/')
      end.once

      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('GET /About.aspx HTTP/1.1')
        expect(args[:issue].id).to eq('Xss')
        expect(args[:node].label).to eq('http://aspnet.testsparker.com/')
      end

      run_import!
    end

    it 'parses links in <external-references> tag' do
      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('"Blind SQL Injection":https://www.owasp.org/index.php/Blind_SQL_Injection')
        expect(args[:text]).to include('"SQL Injection Cheat Sheet[#Blind]":https://www.acunetix.com/blog/web-security/sql-injection-cheat-sheet/#BlindSQLInjections')
        OpenStruct.new(args)
      end

      run_import!
    end
  end
end
