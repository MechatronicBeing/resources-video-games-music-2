# Execute recursive options

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

#Take the parameters
parameter="$1"

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
#Get the others values
read -r MBscriptsDir MBupdateScriptname  <<< $($currentScriptDir/$globalValuesScriptname "MBscriptsDir" "MBupdateScriptname")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#change to root directory
cd "$rootPath"

#Show message
echo "(${currentScript##*/}) EXECUTE RECURSIVE FROM '$categoryName'"

#For each directory, with a name starting with the category
for D in $categoryName*; do
          
  #If it's a directory
  if [[ -d "$D" ]]; then
    #Skip the current directory, do only the sub-dir
    if [[ "$D" != "$categoryName" ]]; then
      #Create the call to the MB update script
      MBupdateScript="$D/${MBscriptsDir}/${MBupdateScriptname}"
      #if the script exist
      if [[ -f "$MBupdateScript" ]]; then
        #Execute it with the parameters
        $MBupdateScript "$parameter"
      fi
    fi
  fi
done
