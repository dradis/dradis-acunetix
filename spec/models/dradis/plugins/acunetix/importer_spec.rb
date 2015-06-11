require "spec_helper"
require "support/fake_node"

module Dradis::Plugins::Acunetix
  describe Importer do

    let(:scan_node) { FakeNode.new }
    let(:content_service) do
      double(
        "ContentService", :logger= => nil, create_node: scan_node,
          create_note: nil, create_issue: nil, create_evidence: nil
      )
    end

    let(:template_service) do
      double(
        "ContentService",
        :logger= => nil,
        process_template: nil,
      )
    end

    before do
      @path = File.expand_path(
        "../../../../../fixtures/files/#{xml_fixture}", __FILE__
      )
      @importer = Importer.new(
        content_service:  content_service,
        template_service: template_service
      )
    end

    let(:xml_fixture) { "simple.acunetix.xml" }

    describe "#import" do
      subject { @importer.import(file: @path) }

      it "creates a 'scan node' with StartUrl as the label" do
        expect(content_service).to receive(:create_node).with(
          label: "testphp.vulnweb.com",
          type:  :host
        )
        subject
      end

      context "when the XML has no <Scan> elements" do
        let(:xml_fixture) { "empty.acunetix.xml" }
        it "returns false and creates an error note" do
          expect(content_service).to receive(:create_note).with(
            text: described_class::NO_SCAN_RESULTS_ERROR_MESSAGE
          )
          expect(subject).to be_falsey
        end
      end


      describe "host nodes" do
        example "extract the 'hostname' property" do
          expect{subject}.to change{scan_node.properties}
          expect(scan_node.properties[:hostname]).to be_present
          expect(scan_node.properties[:hostname]).to eq "testphp.vulnweb.com"
        end

        example "extract any service information" do
          expect{subject}.to change{scan_node.properties}
          expect(scan_node.properties[:service]).to be_present
          expect(scan_node.properties[:service]).to eq "port 80, nginx/1.4.1"
        end
      end
    end

  end
end
