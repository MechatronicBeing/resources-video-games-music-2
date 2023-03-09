#Create readme.md index.html index-noscript.html, with a listing of ALL files and directories of the current dir

#the levels (relative path) to the MB root scripts
rootScriptsLevel=".."
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}/getGlobalValues.sh"

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

#Get the sub-scripts
read -r pagesFilesSubDirname pagesFilesHeaderSubScriptname pagesFilesContentSubScriptname pagesFilesFooterSubScriptname <<< $($currentScriptDir/$globalValuesScriptname  "pagesFilesSubDirname" "pagesFilesHeaderSubScriptname" "pagesFilesContentSubScriptname" "pagesFilesFooterSubScriptname")
#Create the call script for later
executePagesFilesHeaderSubScript="$currentScriptDir/${pagesFilesSubDirname}$pagesFilesHeaderSubScriptname"
executePagesFilesContentSubScript="$currentScriptDir/${pagesFilesSubDirname}$pagesFilesContentSubScriptname"
executePagesFilesFooterSubScript="$currentScriptDir/${pagesFilesSubDirname}$pagesFilesFooterSubScriptname"

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#change to category directory
cd "$rootPath"

#Show current directory
echo "(${currentScript##*/}) CREATING PAGES OF FILES FOR '$categoryName'"

#Execute the sub-script to create header
$executePagesFilesHeaderSubScript

#Execute the sub-script to create content
$executePagesFilesContentSubScript

#Execute the sub-script to create footer
$executePagesFilesFooterSubScript
