#Create static HTML files from Markdown
#(1) if pandoc is installed, use it to generate html

#the (root) category -RELATIVE- directory (containing the FILES)
#Read the information in the global file
categoryDir=$(cat "../_variables/categoryPath.txt")

#keep the current script directory 
currentScriptDir=`pwd`

#track back previous folder to found the category
path="$currentScriptDir" 
down="$categoryDir"
while :; do
  test "$down" = '..' && break
  path=${path%/*}
  down=${down%/*}
done
#Get back one more time (because the last '..' from the previous loop was not executed)
path=${path%/*}
#Take only the final folder
categoryName="${path##*/}"

#File with (readme.html to index.html) lines
readme2indexFile="$currentScriptDir/update-md2html.readme2index.lst"

#change to root CATEGORY directory
cd $categoryDir

#test if pandoc is installed
if [ -x "$(command -v pandoc)" ]; then
  echo "[$0] USING PANDOC FOR '$categoryName'"
  
  #for each md file, use pandoc.
  find . -type f -iname '*.md' | while read f; do 
    #echo "$f > ${f%.*}.html"
    pandoc -f gfm -t html -s "$f" -o "${f%.*}.html"
  done
fi

echo "[$0] RENAME README.HTML TO INDEX.HTML IN '$categoryName'"

#If a "readme.html" is created but WITHOUT an "index.html" in same directory, we save it for later update
#"Add new"
find . -type f -iname 'readme.html' | while read f; do 
  if ! [[ -n $(find ${f%/*} -maxdepth 1 -iname "index.html") ]]; then
    echo "$f" >> "$readme2indexFile"
  fi;
done

#Create a temporary file
echo "" > "$readme2indexFile.tmp"

#for each line ("readme.html" used for "index.html"), rename to index.html
#also purge lines that file are deleted
files=$(cat "$readme2indexFile")
for file in $files
do
  #if the file 'readme.html' exist
  if [ -f "$file" ]; then
    #If there is no 'index.md' file (else it will erase the new index.html)
    if ! [[ -n $(find ${file%/*} -maxdepth 1 -iname "index.md") ]]; then
      #rename the readme.htm to index.html
      mv $file "${file%/*}/index.html"
      #add the file to the list
      echo "$file" >> "$readme2indexFile.tmp"
    fi
  fi
done

#rename the temporary file (overwrite) to the new file 
mv -f "$readme2indexFile.tmp" "$readme2indexFile"
