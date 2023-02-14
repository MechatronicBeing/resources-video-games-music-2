#Create dynamic HTML files from Markdown
#WARNING : in development/testing.

#scripts directory 
scriptsDir="MechatronicBeing/scripts/web/md2html"
scriptName="md2html.js"

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

#echo "[$0] GENERATE dynamic html pages (with 'md2html.js' webscript)"

find . -type f -iname '*.md' | while read f; do   

  #Remove the substring from start to . (used in 'find' command)
  fileName="${f#*.}"
  #Remove the / at start
  fileNameFull="${fileName#*/}"
  
  echo "$f / $fileNameFull"
  
  #the root -RELATIVE- directory used IN the final page [CALCULATED from the target dir]
  #Get all the '/' (remove all others characters) in path
  relativeFilePath=`echo "$fileNameFull" | tr -cd /`
  #If the relative path is not empty (not in the root), then
  if [[ "$relativeFilePath" != "" ]]; then
    #Add .. for each / (and add one at the beginning)
    relativeFilePath="..${relativeFilePath//\//\/..}"
  else
    relativeFilePath="."
  fi

  #echo "$f > ${f%.*}.html"
  
  #Create a new html file, with scripts (trying to load the md file) and noscript (embed the mdfile)
  echo "<!DOCTYPE html>" > "${f%.*}.html"
  echo "<html>" >> "${f%.*}.html"
  echo "<head>" >> "${f%.*}.html"
  echo "<title>${f%.*}</title>" >> "${f%.*}.html"
  echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> "${f%.*}.html"
  echo "<meta charset=\"UTF-8\">" >> "${f%.*}.html"
  echo "</head>" >> "${f%.*}.html"
  echo "<body>" >> "${f%.*}.html"
  echo "<div id=\"divMD\" data-mdFile=\"${f##*/}\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></div>" >> "${f%.*}.html"
  echo "<noscript><embed id=\"embedMD\" src=\"${f##*/}\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></noscript>" >> "${f%.*}.html"
  echo "<script src=\"$relativeFilePath/$scriptsDir/$scriptName\"></script>" >> "${f%.*}.html"
  echo "</body>" >> "${f%.*}.html"
  echo "</html>" >> "${f%.*}.html"
done


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
