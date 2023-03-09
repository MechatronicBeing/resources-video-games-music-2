#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

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
read -r pagesOtherSubScriptDir pagesOtherRootSubScriptname pagesOtherListSubScriptname <<< $($currentScriptDir/$globalValuesScriptname "pagesOtherSubScriptDir" "pagesOtherRootSubScriptname" "pagesOtherListSubScriptname")
executePagesOtherRootScript="$currentScriptDir/${pagesOtherSubScriptDir}${pagesOtherRootSubScriptname}"
executePagesOtherListScriptname="$currentScriptDir/${pagesOtherSubScriptDir}${pagesOtherListSubScriptname}"

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#change to root CATEGORY directory
cd "$categoryPath"

echo "(${currentScript##*/}) CREATING OTHER PAGES"
 
#Execute the list page creation
$executePagesOtherListScriptname  "$userChoices"

#Execute the root page creation
$executePagesOtherRootScript "$userChoices"
