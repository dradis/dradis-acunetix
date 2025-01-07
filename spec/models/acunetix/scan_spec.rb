require "spec_helper"

describe Acunetix::Scan do

  before do
    path    = "../../../fixtures/files/simple.acunetix.xml"
    raw_xml = File.read(File.expand_path(path, __FILE__))
    @xml    = Nokogiri::XML(raw_xml)
    @scan   = described_class.new(@xml.at_xpath("./ScanGroup/Scan"))
  end

  describe "#respond_to?" do
    it "returns true for supported tags" do
      Acunetix::Scan::SUPPORTED_TAGS.each do |tag|
        expect(@scan).to respond_to(tag)
      end
    end
  end

  describe "creating a Scan object with the wrong XML element" do
    it "raises an error" do
      expect{ described_class.new(@xml) }.to raise_error(RuntimeError, /Invalid XML/)
    end
  end

  describe "tag methods" do
    it "returns the text of the tag" do
      expect(@scan.name).to eq "Scan Thread 1 ( http://testphp.vulnweb.com:80/ )"
    end

    it "handles tag names with acronyms correctly" do
      expect(@scan.start_url).to eq "http://testphp.vulnweb.com:80/"
    end
  end

  describe "#start_url_host" do
    it "returns the 'host' part of the <StartUrl> tag" do
      expect(@scan.start_url_host).to eq "testphp.vulnweb.com"
    end
  end


  describe "#start_url_port" do
    it "returns the 'port' part of the <StartUrl> tag" do
      expect(@scan.start_url_port).to eq 80
    end
  end


  describe "#hostname" do
    it "is an alias for 'start_url_host'" do
      expect(@scan.hostname).not_to be_nil
      expect(@scan.hostname).to eq @scan.start_url_host
    end
  end

  describe "#service" do
    it "returns banner info and port number" do
      expect(@scan.service).to eq "port 80, nginx/1.4.1"
    end
  end


  describe "#report_items" do
    it "returns the XML <ReportItem> tags" do
      result = @scan.report_items
      expect(result).to be_a(Nokogiri::XML::NodeSet)
      result.each do |item|
        expect(item.name).to eq "ReportItem"
      end
    end
  end

end
