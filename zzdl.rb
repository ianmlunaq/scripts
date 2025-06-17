#!/usr/bin/ruby

require 'optparse'
require 'open-uri'
require 'ruby-progressbar'

options = {}
OptionParser.new do |opts|
    #opts.banner = "Usage: example.rb [options]"
    opts.on("-u URL", "URL of album without page indicator (ex. \"index.html\")") { |o| options[:url] = o }
    opts.on("-c COOKIE", "cf_clearance cookie passed as string") { |o| options[:cookie] = o }
end.parse!

#system("wget2 -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' --no-cookies --header 'Cookie: cf_clearance=${2}' '${1}index.html' -O ddfiles/dd1.html")

progressbar = ProgressBar.create(:starting_at => 0,
                                 :total => nil,
                                 :title => "Scanning gallery",
                                 :format => "%t: [%B] (%c/%u)")

url = options[:url]

#Opens index page & loads it into memory as an array of strings
page_html = open(url).read.split("\n")

# Get number of pages in gallery
pages_amt = page_html.grep(/1 \/ *[0-9]*/)
pages_amt.empty? ? pages_amt = 1 : pages_amt = pages_amt[0].split('/')[1].to_i

# Get photoset name & make a directory with that name to contain downloads
set_name = page_html.grep(/<title>/)[0].split(/[<>]/)[2]
progressbar.log "Found #{set_name}"
set_name << ".dupe" while Dir.exist?("#{set_name}")
Dir.mkdir("#{set_name}")

# Scans gallery pages for full img page links
img_html = []
(1..pages_amt).each do |num|
    url.sub!(/\/\S{1,6}\.html/, "/page-#{num}.html") #todo: fix flimsy regex
    page_html = open(url).read.split("\n")
    
    # Add semi-links from full img html pages to array
    img_html << page_html[77].scan(/\/viewimage[^"]*\.html/)

    progressbar.increment
end

progressbar.total = img_html.flatten!.count
progressbar.progress = 0
progressbar.title = "Download progress"
progressbar.log "Found #{img_html.count} images\nSaving images to \"#{Dir.pwd}/#{set_name}\""

# Goes through each full image page & saves full image locally 
index = 0
img_html.each do |page|
    index += 1
    img_page_url = "https://zzup.com" + page
    img_page_html = open(img_page_url).read.split("\n")
    full_img_url = "https://zzup.com" + img_page_html.grep(/zzup.com.jpg/)[0].split("\"")[1]
    File.open("#{set_name}/#{set_name}.#{index}.jpg", "w") { |file| file.write(open(full_img_url).read)}
    progressbar.increment
end

progressbar.log "Done downloading!"
