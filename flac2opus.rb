#!/usr/bin/ruby

require 'optparse'
require 'rainbow/refinement'

using Rainbow

options = {}
OptionParser.new do |opts|
    #opts.banner = "Usage: example.rb [options]"
    opts.on("-d DIRECTORY", "Target directory") { |o| options[:directory] = o }
end.parse!

if options[:directory]
    workingDir = Dir.new(options[:directory])
    Dir.chdir(workingDir)

    allFilenames = workingDir.children
    flacFilenames = Array.new
    opusFilenames = Array.new
    currentDir = Dir.pwd.split('/').last
    opusDir = currentDir + "_opus_converts"

    puts "Flac files to be converted to opus:"

    allFilenames.sort!.each do |filename|
        if filename.include? ".flac"
            flacFilenames.push(filename)
            puts "\t#{currentDir}/\"#{filename}\""
        end
    end

    puts "\nTotal files to be converted: #{flacFilenames.count}"

    if Dir.exist?("#{opusDir}")
        puts "#{currentDir}/#{opusDir} already exists! Canceling conversion...".red
    elsif flacFilenames.count == 0
        puts "No flac files found!".yellow
    else
        Dir.mkdir("#{opusDir}")
        puts "Files will be placed in: #{Dir.pwd}/#{opusDir}\n\n"

        successEncodes = Array.new
        failedEncodes = Array.new

        flacFilenames.each do |flacFilename|
            opusFilename = flacFilename.sub(".flac", ".opus")
            puts "Encoding \"#{opusFilename}\"...".yellow

            puts "opusenc \"#{flacFilename}\" \"#{opusDir}\"/\"#{opusFilename}\""

            if system("opusenc \"#{flacFilename}\" \"#{opusDir}\"/\"#{opusFilename}\"")
                successEncodes.push(opusFilename)
                puts "Successfully encoded \"#{opusFilename}\"\n".green
            else
                failedEncodes.push(opusFilename)
                puts "Could not encode \"#{flacFilename}\"!\n".red
            end
        end

        unless successEncodes.empty?
            puts "Successfully converted #{successEncodes.count} out of #{flacFilenames.count} flac files:"
            successEncodes.each do |filename|
                puts "\t\"#{filename}\"".green
            end
        end

        unless failedEncodes.empty?
            puts "Failed to convert #{failedEncodes.count} out of #{flacFilenames.count} flac files:"
            failedEncodes.each do |filename|
                puts "\t\"#{filename}\"".red
            end
        end
    end
else
    puts "No directory provided! Use -h for help"
end

