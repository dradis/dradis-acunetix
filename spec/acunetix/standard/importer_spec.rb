# To run, execute from Dradis main app folder:
# bin/rspec [dradis-acunetix path]/spec/acunetix/standard/importer_spec.rb
require 'rails_helper'
require 'ostruct'
require File.expand_path('../../../support/spec_macros.rb', __FILE__)

include SpecMacros

module Dradis::Plugins
  describe Acunetix::Standard::Importer do
    before do
      @fixtures_dir = File.expand_path('../../../fixtures/files/', __FILE__)
    end

    before(:each) do
      stub_content_service

      @importer = described_class.new(content_service: @content_service)
    end

    def run_import!
      @importer.import(file: @fixtures_dir + '/simple.acunetix.xml')
    end

    it 'creates nodes as needed' do
      expect(@content_service).to receive(:create_node).with(hash_including label: 'testphp.vulnweb.com', type: :host).once

      run_import!
    end

    it 'creates notes as needed' do
      expect(@content_service).to receive(:create_note) do |args|
        expect(args[:text]).to include('Scan Thread 1')
        expect(args[:node].label).to eq('testphp.vulnweb.com')
      end.once

      run_import!
    end

    it 'creates issues from report_item elements' do
      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('HTML form without CSRF protection')
        expect(args[:id]).to eq('Crawler/HTML form without CSRF protection')
      end.once

      expect(@content_service).to receive(:create_issue) do |args|
        expect(args[:text]).to include('Clickjacking: X-Frame-Options header missing')
        expect(args[:id]).to eq('Scripting (Clickjacking_X_Frame_Options.script)/Clickjacking: X-Frame-Options header missing')
      end.once

      run_import!
    end

    it 'creates evidence from report_item elements' do
      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('Form name:')
        expect(args[:issue].id).to eq('Crawler/HTML form without CSRF protection')
        expect(args[:node].label).to eq('testphp.vulnweb.com')
      end.once

      expect(@content_service).to receive(:create_evidence) do |args|
        expect(args[:content]).to include('Web Server')
        expect(args[:issue].id).to eq('Scripting (Clickjacking_X_Frame_Options.script)/Clickjacking: X-Frame-Options header missing')
        expect(args[:node].label).to eq('testphp.vulnweb.com')
      end

      run_import!
    end

    describe 'Regression tests' do
      # Regression test for github.com/dradis/dradis-nexpose/issues/1
      describe 'Source HTML parsing' do
        it 'identifies code/pre blocks and replaces them with the Textile equivalent' do

          expect(@content_service).to receive(:create_issue) do |args|
            expect(args[:text]).to include('SQL injection (verified)')
            expect(args[:text]).not_to include('<code>')
            expect(args[:text]).not_to include('<pre')
            expect(args[:id]).to eq('Scripting (Sql_Injection.script)/SQL injection (verified)')
          end.once

          @importer.import(file: @fixtures_dir + '/code-pre.acunetix.xml')
        end
      end

      # Regression test to make sure that commas are replaced with decimals in the CVSSv3 scores
      describe 'CVSS clean up decimals' do
        it 'identifies commas used as decimals in CVSSv3 scores and replaces them with periods' do

          expect(@content_service).to receive(:create_issue) do |args|
            expect(args[:text]).to include('5.3')
          end

          @importer.import(file: @fixtures_dir + '/commas-format.acunetix.xml')
        end
      end

    end
  end
end
