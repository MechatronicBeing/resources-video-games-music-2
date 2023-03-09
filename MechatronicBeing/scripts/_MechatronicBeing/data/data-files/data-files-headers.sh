#Create README.md AND INDEX.HTML, with a listing of ALL files and directories of the current dir
#Note : index.html differ from readme because of Downloading option
#Why ? Inputs/checkboxes are erased from the tables (with a markdown to html converter...)
#Readme is preserved for the online repository...

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

#Get the data values
read -r dataPath dataFilesHeaderPrefix dataFilesRawfile dataFilesMDfile dataFilesJSfile dataFilesHTMLfile <<< $($currentScriptDir/$globalValuesScriptname "filesDataPath" "dataFilesHeaderPrefix" "dataFilesRawfile" "dataFilesMDfile" "dataFilesJSfile" "dataFilesHTMLfile")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
#Add 2 more folders : the final folder (not in the targetDir)
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir" 1)

#Variables for main Identifier AND location
mainItemId="${categoryName}/"
mainLocation="${categoryName}/"
#The git path
gitPath="${mainLocation}.git"

#change to ROOT directory
cd "$rootPath"

#Show current directory
echo "(${currentScript##*/}) CREATING HEADERS LIST OF FILES FOR '$categoryName'"

#Create data directory (if not exist)
if [[ ! -d "$categoryPath/$dataPath/$dataFilesHeaderPrefix" ]]; then
  mkdir -p "$categoryPath/$dataPath/$dataFilesHeaderPrefix"
fi

#Write information in a MD file
echo "| Name | Last modified | Type | Size | #Files | #Folders | MD5 |  " > "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${dataFilesMDfile}"
echo "| ---- | ------------- | ---- |----- | ------ | -------- | --- |  " >> "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${dataFilesMDfile}"

#Prepare HTML headers
dataHTMLheader=()
dataHTMLheader[0]="Select"
dataHTMLheader[1]="Name"
dataHTMLheader[2]="Last modified"
dataHTMLheader[3]="Type"
dataHTMLheader[4]="Size"
dataHTMLheader[5]="#Files"
dataHTMLheader[6]="#Folders"
dataHTMLheader[7]="MD5"
lineHTMLheader=""

#Write information into HTML file
for((i=0;i<${#dataHTMLheader[@]};i++)); do 
  #add the information to the html file
  lineHTMLheader="${lineHTMLheader}<th>${dataHTMLheader[$i]}</th>"
done

#Write information in a HTML file
echo "<thead><tr>${lineHTMLheader}</tr></thead>" > "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${dataFilesHTMLfile}"
 