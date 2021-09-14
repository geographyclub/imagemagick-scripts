#!/bin/bash

file='/home/steve/Downloads/tmp/output1.csv'
dir='/home/steve/Downloads/tmp'
rm -f /home/steve/Downloads/tmp/*

echo "export from psql..."
psql -d grids -t -A -F"," -c "SELECT * FROM places WHERE sov0name IN ('Italy') AND scalerank IN (0,1,2,3,4)" > ${file}

echo "svg..."
cat ${file} | while read line; do 
  id=($(echo ${line} | awk -F "," '{print $1}'))
  words=($(echo ${line} | awk -F "," '{print $7}' | tr '-' ' '))
  lon=($(echo ${line} | awk -F "," '{print $23}'))
  lat=($(echo ${line} | awk -F "," '{print $22}'))
  for ((a=0; a<${#words[@]}; a=a+1)); do
    convert -background White -fill Black -font '/home/steve/.fonts/Google Webfonts/VT323-Regular.ttf' -size 1000x -interline-spacing 0 label:${words[a]^^} -trim +repage -resize 1000x -bordercolor White -border 10 /home/steve/Downloads/tmp/word${a}.ppm
  done
  convert -append $(ls -v /home/steve/Downloads/tmp/word*.ppm) /home/steve/Downloads/tmp/id_${id}.ppm
  potrace --progress -b svg --alphamax 1.0 --color \#000000 --opttolerance 0.2 --turdsize 0 --turnpolicy min --unit 10 --output ${dir}/id_${id}.svg /home/steve/Downloads/tmp/id_${id}.ppm
done

echo "color..."
rm -f ${dir}/*b.svg
ls ${dir}/*.svg | while read file; do 
  cat ${file} | sed 's/fill=\"#000000\"/fill=\"#ffffff\"/g' | sed 's/stroke=\"none\"/stroke=\"#000000\" stroke-width=\"10\" vector-effect=\"non-scaling-stroke\"/g' > ${file%.svg}b.svg
done
