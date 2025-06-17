#!/usr/bin/ruby

require 'optparse'
require 'ruby-progressbar'

options = {}
OptionParser.new do |opts|
    #opts.banner = "Usage: example.rb [options]"
    opts.on("-d DIR", "Directory containing VOB files") { |o| options[:dir] = o }
end.parse!

workingDir = Dir.new(options[:dir])
Dir.chdir(workingDir)
allFilenames = workingDir.children

allFilenames.grep(/.VOB/).sort!.each do |vob_file|
  system("ffmpeg -i #{vob_file} -c:v copy -c:a copy #{vob_file[5]}.mp4")
end

system("mkvmerge --generate-chapters when-appending -o #{Dir.pwd.split('/').last}.mkv '[' *.mp4 ']'")