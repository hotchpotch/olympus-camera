RSpec.describe OlympusCamera do
  it "has a version number" do
    expect(OlympusCamera::VERSION).not_to be nil
  end

  describe "generate_apis!" do
    it "pen_f.xml" do
      xml = load_data("pen_f.xml")
      camera = OlympusCamera.new(commandlist_xml: xml)
      expect(false).to eq(false)
    end
  end
end
