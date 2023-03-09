#Rename readme.html to index.html if needed
#Note : not only readme.html, can be used with other files

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../.."
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}/getGlobalValues.sh"

#keep the current script directory (= the information of $0 ONLY !!!)
currentScript="${0#./}"
currentScriptDir="${currentScript%/*}"

#INIT VARIABLES WITH GLOBAL VALUES
#the relative category path 
relativeCategoryPath=$($currentScriptDir/$globalValuesScriptname "categoryPath")
#Get the findParentDirectory script function
read -r MBfunctionsScriptsDirname findParentDirectoryScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findParentDirectoryScriptname")
#Create the call to the script later
executeFindParentDirectoryScript="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findParentDirectoryScriptname"
#Get the findRelativePath script function
read -r MBfunctionsScriptsDirname findRelativePathScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findRelativePathScriptname")
#Create the call to the script later
executeFindRelativePathScriptname="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findRelativePathScriptname"
#Get the others parameters
read -r scriptsDir scriptName <<< $($currentScriptDir/$globalValuesScriptname  "md2htmlwebScriptDir" "md2htmlwebScriptname")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#get the file with (readme.html to index.html) lines
readme2indexFilename=$($currentScriptDir/$globalValuesScriptname "readme2indexFilename")

#change to root CATEGORY directory
cd "$categoryPath"

echo "[${currentScript##*/}] RENAMING README.HTML TO INDEX.HTML FOR '$categoryName'"

#for each line ("readme.html" used for "index.html"), rename to index.html
#also purge lines that file are deleted
files=$(cat "$currentScriptDir/$readme2indexFilename")
for file in $files
do

  #if the file 'readme.html' exist
  if [[ -f "${file}" ]]; then
  
    #If there is no 'index.md' file (else it will erase the new index.html)
    if ! [[ -n $(find ${file%/*} -maxdepth 1 -iname "index.md") ]]; then
      #Show message
      echo "[${currentScript##*/}] RENAMING ${file} TO index.html FOR '$categoryName'"
      #rename the readme.htm to index.html
      mv "${file}" "${file%/*}/index.html"
    fi
  fi
done

