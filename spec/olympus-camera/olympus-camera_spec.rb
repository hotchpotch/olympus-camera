RSpec.describe OlympusCamera do
  it "has a version number" do
    expect(OlympusCamera::VERSION).not_to be nil
  end

  describe "generate apis" do
    it "pen_f.xml" do
      xml = load_data("pen_f.xml")
      camera = OlympusCamera.new(commandlist_xml: xml)
      expect(camera.api_version).to eq("2.60")
      expect(camera.support_funcs).to eq(["web", "remote", "gps", "release"])

      expect(camera.api_list.detect { |(name, params)| name == "get_imglist" }).to eq(["get_imglist", [{ "DIR" => OlympusCamera::ANY }]])
    end
  end
end
