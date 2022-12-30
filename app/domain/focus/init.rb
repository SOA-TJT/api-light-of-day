folders = %w[entities lib repositories mapper]
folders.each do |folder|
  Dir.glob("#{__dir__}/#{folder}/**/*.rb").each do |file|
    puts file
    require_relative file
  end
end
