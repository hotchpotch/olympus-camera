require "olympus-camera"
require "pp"

camera = OlympusCamera.new
model = camera.get_caminfo["model"]

puts <<-DOC
# Olympus #{model ? model[0] : ""} API

- `api_list()`
- `all_images()`
- `get_image(path)`

## Auto generated API (instance methods)

DOC

generated_api_methods = camera.api_list.map do |list|
  name, args = list
  if args && args.length > 0
    args.map { |args|
      "#{name}(#{args.pretty_print_inspect})"
    }
  else
    "#{name}()"
  end
end.flatten

puts generated_api_methods.map { |m| "- `#{m}`" }.join("\n")
