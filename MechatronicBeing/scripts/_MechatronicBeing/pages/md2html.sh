#Create static HTML files from Markdown
#(1) if pandoc is installed, use it to generate html

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

#Char to execute the script
charUpdateHtmlStaticScript="h"
charUpdateHtmlDynamicScript="H"

#Get only the 1st parameter
userChoices="${1%% *}"

#keep the current script directory (= the information of $0 AND PWD !!!)
currentScript="$PWD/${0#./}"
currentScriptDir="${currentScript%/*}"

#INIT VARIABLES WITH GLOBAL VALUES
#the relative category path 
relativeCategoryPath=$($currentScriptDir/$globalValuesScriptname "categoryPath")
#Get the findParentDirectory script function
read -r MBfunctionsScriptsDirname findParentDirectoryScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findParentDirectoryScriptname")
#Create the call to the script later
executeFindParentDirectoryScript="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findParentDirectoryScriptname"
#get the script for renaming (readme.html to index.html)
read -r updateHtmlSubScriptsDir updateHtmlStaticScriptname updateHtmlDynamicScriptname readme2indexScriptname <<< $($currentScriptDir/$globalValuesScriptname "updateHtmlSubScriptsDir" "updateHtmlStaticScriptname" "updateHtmlDynamicScriptname" "readme2indexScriptname")
executeUpdateHtmlStaticScript="$currentScriptDir/${updateHtmlSubScriptsDir}${updateHtmlStaticScriptname}"
executeUpdateHtmlDynamicScript="$currentScriptDir/${updateHtmlSubScriptsDir}${updateHtmlDynamicScriptname}"
executeReadme2indexScript="$currentScriptDir/${updateHtmlSubScriptsDir}${readme2indexScriptname}"

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

echo "(${currentScript##*/}) GENERATING HTML PAGES"

#for each md file, execute du -time to get the datetime of last modified before the full filepath.
find . -type f -iname '*.md' -exec du --time {} + | while IFS=$'\t' read -r sizeFile datetimeOfLastModifFile filepathMD; do 
  
  #Get file without extension
  pathnameWithoutFileExt="${filepathMD%.*}"
  filename="${filepathMD##*/}"
  fileLocation="${filepathMD%/*}"
  
  #Create the html files (name file or index.html -if renamed-)
  htmlFileCreated="${pathnameWithoutFileExt}.html"
  htmlFileRenamed="${fileLocation}/index.html"
  
  if [[ -f "$htmlFileCreated" ]]; then
    #The .html exist (previously generated), get the datatime of last modification
    IFS=$'\t' read -r size htmlFileDTLastModification filename <<< $(du --time --time-style=+'%Y-%m-%d %H:%M:%S' "$htmlFileCreated")
  
  elif [[ "${filename^^}" == "README.MD" && -f "$htmlFileRenamed" && ! -f "${fileLocation}/index.md" ]]; then
    #File is readme.md, there is a previous index.html but no index.md, get the datetime of last modification of the index.html (maybe the readme.html was renamed to index.html ?)
    IFS=$'\t' read -r size htmlFileDTLastModification filename <<< $(du --time --time-style=+'%Y-%m-%d %H:%M:%S' "$htmlFileRenamed")
  else
    #no html file founded : no date of modification.
    htmlFileDTLastModification=""
  fi
  #If the date time of last modification of MD file is newer than the date of modification (creation) of the html file
  if [[ "$datetimeOfLastModifFile" > "$htmlFileDTLastModification" ]]; then
  
    #Remove './' at start
    filepathMD="${filepathMD#./}" 
  
    #Generate the html...
    if [[ "$userChoices" == *"$charUpdateHtmlStaticScript"* ]]; then
      #Using the static script
      $executeUpdateHtmlStaticScript "$filepathMD"
    elif [[ "$userChoices" == *"$charUpdateHtmlDynamicScript"* ]]; then
      #Using the dynamic script
      $executeUpdateHtmlDynamicScript "$filepathMD"
    fi
    
    #If the filename is README and the html page was generated, BUT NO index.html NO index.md inside the folder
    if [[ "${filename^^}" == "README" && -f "$htmlFileCreated" && ! -f "$htmlFileRenamed" && ! -f "${fileLocation}/index.md" ]]; then
      #Add it to the readme2index file
      echo "$htmlFileCreated" >> "$currentScriptDir/${updateHtmlSubScriptsDir}$readme2indexFilename"
    fi
  fi
done

#Ask the sub-script to rename the readme.html to index.html needed
$executeReadme2indexScript
