require "olympus-camera"

camera = OlympusCamera.new
model = camera.get_caminfo["model"]

puts "Hi, #{model[0]}!"

camera.switch_cammode({ "mode" => "play" })
images = camera.all_images

camera.switch_cammode({ "mode" => "shutter" })
puts "Take a photo!"
camera.exec_shutter({ "com" => "1st2ndpush" })
sleep 2

camera.exec_shutter({ "com" => "2nd1strelease" })
puts "Finished"
sleep 1
camera.switch_cammode({ "mode" => "play" })
after_images = camera.all_images

new_images = after_images - images

if new_images
  puts "found new image(s):"
  puts new_images.join("\n")
  puts "download image(s):"
  new_images.each do |image|
    filename = image.split("/")[-1]
    puts "GET: #{image}"
    data = camera.get_image(image)
    puts "WRITE: #{filename} (#{data.size} byte)"
    open(filename, "w") { |f| f.puts data }
  end
end
