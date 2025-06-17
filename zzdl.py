#!/bin/zsh

#rm -fr zz
#rm -fr ddfiles

wget2 -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' --no-cookies --header "Cookie: cf_clearance=${2}" "${1}index.html" -O ddfiles/dd1.html

# Get number of pages
declare -i pages
pages=$(grep -o '1 / *[0-9]*' ddfiles/dd1.html | sed 's/1 \/ //g')

title=$(grep -o '<title>[^<]*' ddfiles/dd1.html | sed 's/<title>//')

grep -o '/viewimage[^"]*\.html' ddfiles/dd1.html | sed 's|^|https:\/\/zzup.com|' > ddfiles/indImgList.txt

for ((i = 2; i <= pages; i++))
do
    if wget2 -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' --no-cookies --header "Cookie: cf_clearance=${2}" -q --spider "${1}page-$i.html"; then
        echo "File exists"
        wget2 -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' --no-cookies --header "Cookie: cf_clearance=${2}" "${1}page-$i.html" -O "ddfiles/dd$i.html"
        grep -o '/viewimage[^"]*\.html' "ddfiles/dd$i.html" | sed 's/^/https:\/\/zzup.com/' >> ddfiles/indImgList.txt
    else
        echo "File does not exist"
        read -p "Press key to continue.. " -n1 -s
    fi
done

aria2c -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' --header="Cookie: cf_clearance=${2}" -j 16 -x 5 -i ddfiles/indImgList.txt -d zz/

# gets image links from image html pages (2 identical image links in each page)
grep -oh '/[^"]*\zzup.com.jpg' zz/*.html | sort -n >> ddfiles/fullImgList.txt

# prepends "https://zzup.com" to each line
sed 's|^|https:\/\/zzup.com|' ddfiles/fullImgList.txt > ddfiles/fullImgListA.txt

# removes every other line to remove repeating links
sed 'n; d' ddfiles/fullImgListA.txt > ddfiles/fullImgListB.txt   

aria2c -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' --header="Cookie: cf_clearance=${2}" -j 16 -x 5 -i ddfiles/fullImgListB.txt -d "${title}/"

#rm -fr zz
#rm -fr ddfiles
