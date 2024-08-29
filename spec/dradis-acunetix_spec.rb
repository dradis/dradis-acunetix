require 'spec_helper'
require 'ostruct'

module Dradis::Plugins
  describe 'Acunetix::Standard regression tests' do
    before(:each) do
      stub_mapping_service
      stub_content_service

      @importer = Acunetix::Standard::Importer.new(
        content_service: @content_service,
      )
    end

    # Regression test for github.com/dradis/dradis-nexpose/issues/1
    describe "Source HTML parsing" do
      it "identifies code/pre blocks and replaces them with the Textile equivalent" do

        expect(@content_service).to receive(:create_issue) do |args|
          expect(args[:text]).to include('SQL injection (verified)')
          expect(args[:text]).not_to include("<code>")
          expect(args[:text]).not_to include("<pre")
          expect(args[:id]).to eq("Scripting (Sql_Injection.script)/SQL injection (verified)")
        end.once

        @importer.import(file: 'spec/fixtures/files/code-pre.acunetix.xml')
      end
    end

    # Regression test to make sure that commas are replaced with decimals in the CVSSv3 scores
    describe "CVSS clean up decimals" do
      it "identifies commas used as decimals in CVSSv3 scores and replaces them with periods" do

        expect(@content_service).to receive(:create_issue) do |args|
          expect(args[:text]).to include('5.3')
        end

        @importer.import(file: 'spec/fixtures/files/commas-format.acunetix.xml')
      end
    end

  end
end
