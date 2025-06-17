#!/usr/bin/ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  #opts.banner = "Usage: example.rb [options]"
  opts.on("-v VIDEO_FILE", "Target video") { |o| options[:video] = o }
end.parse!

if options[:video]
  clip_count = 6
  clip_length_secs = 5
  total_secs_rounded = `ffprobe -i #{options[:video]} -show_entries format=duration -v quiet -of csv='p=0'`.to_i
  
  clip_spacing = (total_secs_rounded - (total_secs_rounded / clip_count)) / 6
  place = clip_spacing

  clip_files = Array.new

  for i in 1..clip_count
    clipname = ".#{options[:video]}_#{i}_tmpclip.mp4"
    clip_files.push(clipname)

    echo = system("echo \"file '#{clipname}'\" >> .#{options[:video]}_tmpmontage.txt")
    clipping = system("ffmpeg -ss #{place} -i #{options[:video]} -t #{clip_length_secs} -c copy #{clipname}")

    place += clip_spacing
  end

  concat = system("ffmpeg -f concat -safe 0 -i .#{options[:video]}_tmpmontage.txt -c:v libsvtav1 -crf 10 #{options[:video]}_montage.mp4")

  for file in clip_files
    if File.delete(file)
      puts "Deleted #{file}"
    end
  end

  if File.delete(".#{options[:video]}_tmpmontage.txt")
    puts "Deleted txt"
  end

end