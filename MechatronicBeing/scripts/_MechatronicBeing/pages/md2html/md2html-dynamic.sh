#Create dynamic HTML files from Markdown
#WARNING : in development/testing.

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

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
read -r  scriptsDir scriptName spaceEscape <<< $($currentScriptDir/$globalValuesScriptname  "updateHtmlDynamicWebDirname" "updateHtmlDynamicWebScriptname" "escapeSpacesInUrl")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#Get the parameter filepath
fileToConvert="$1"

#Create the html files (name file or index.html -if renamed-)
pathWithoutExt="${fileToConvert%.*}"
htmlFileCreated="${pathWithoutExt}.html"
fileNameWithoutExt="${pathWithoutExt##*/}"

echo "((${currentScript##*/})) GENERATING DYNAMIC '${htmlFileCreated}'"

#escape space in url
filenameProtected="${fileNameWithoutExt// /$spaceEscape}"

#the -RELATIVE- path used IN the final page
relativeFilePath=$($executeFindRelativePathScriptname "${filepathMD#./}" -1)

#Create a new html file, with scripts (trying to load the md file) and noscript (embed the mdfile)
echo "<!DOCTYPE html>" > "${htmlFileCreated}"
echo "<html>" >> "${htmlFileCreated}"
echo "<head>" >> "${htmlFileCreated}"
echo "<title>${fileNameWithoutExt%.*}</title>" >> "${htmlFileCreated}"
echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> "${htmlFileCreated}"
echo "<meta charset=\"UTF-8\">" >> "${htmlFileCreated}"
echo "</head>" >> "${htmlFileCreated}"
echo "<body>" >> "${htmlFileCreated}"
echo "<div id=\"divMD\" data-mdFile=\"${filenameProtected}\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></div>" >> "${htmlFileCreated}"
echo "<noscript><embed id=\"embedMD\" src=\"${filenameProtected}\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></noscript>" >> "${htmlFileCreated}"
echo "<script src=\"$relativeFilePath/$scriptsDir/$scriptName\"></script>" >> "${htmlFileCreated}"
echo "</body>" >> "${htmlFileCreated}"
echo "</html>" >> "${htmlFileCreated}"
