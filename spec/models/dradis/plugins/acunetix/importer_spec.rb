require "spec_helper"

module Dradis::Plugins::Acunetix
  describe Importer do

    let(:content_service) do
      double(
        "ContentService", :logger= => nil, create_node: nil,
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
    end

  end
end
