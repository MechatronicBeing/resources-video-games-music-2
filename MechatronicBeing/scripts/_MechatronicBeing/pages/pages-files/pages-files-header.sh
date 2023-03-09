#Create header for pages-html

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
read -r dataPath dataFilesHeaderPrefix dataFilesMDfile dataFilesJSfile <<< $($currentScriptDir/$globalValuesScriptname "filesDataPath" "dataFilesHeaderPrefix" "dataFilesMDfile")
#Get the others values
read -r targetDir pagesFilesMDFilename pagesFilesHTMLFilename zipScriptTarget MBStylesDir filesStyleFilename  <<< $($currentScriptDir/$globalValuesScriptname "pagesFilesTargetDir" "pagesFilesMDFilename" "pagesFilesHTMLFilename" "zipWebScriptTarget" "MBStylesDir" "filesStyleFilename")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir")

#Title
htmlTitle="Files in $categoryName/"

#change to category directory
cd "$rootPath"

#Create target directory (if not exist)
if [[ ! -d "$categoryPath/$targetDir" ]]; then
  mkdir -p "$categoryPath/$targetDir"
fi

#Show current directory
echo "((${currentScript##*/})) CREATING HEADER-PAGE OF FILES FOR '$categoryName'"
      
#MD FILE HEADER
echo "## $htmlTitle  " > "$categoryPath/$targetDir/$pagesFilesMDFilename"
echo "*Date : $(date +%F)*  " >> "$categoryPath/$targetDir/$pagesFilesMDFilename"
echo "*Note : actual values may vary !*  " >> "$categoryPath/$targetDir/$pagesFilesMDFilename"
echo "  " >> "$categoryPath/$targetDir/$pagesFilesMDFilename"

#HTML HEADER
echo "<!DOCTYPE html>" > "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"\" xml:lang=\"\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<head>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <meta charset=\"utf-8\" />" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=yes\" />" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <title>$htmlTitle</title>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <link rel=\"stylesheet\" href=\"$showedRelativeFinalTarget/$MBStylesDir/$filesStyleFilename\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "</head>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<body>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo " <div id=\"_bodyContainer\" style=\"position: relative; min-height: 100vh;\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "   <div id=\"_bodyContent\" style=\"padding-bottom: 2.5rem;\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <h2>$htmlTitle</h2>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <p><em>Date : $(date +%F)</em><br />" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <em>Note : actual values may vary !</em></p>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#Add a details tag : VIEW
echo "<details style=\"border: 1px #ffffff; outline: solid; display: inline-block;\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <summary style=\"border: 1px #ffffff; outline: solid; cursor: pointer; \">View</summary>" >>"$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#Need Add an empty line to validate details
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Only folders<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Only files<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Extension<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Show last modified<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Show Type<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Show Size<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Show #Files<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input type=\"checkbox\" id=\"${itemId}_\" >Show #Folders<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#close the details tag
echo "</details>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#Need Add an empty line to validate details
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#Add a details tag
echo "<details style=\"border: 1px #ffffff; outline: solid; display: inline-block;\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <summary style=\"border: 1px #ffffff; outline: solid; cursor: pointer; \">Search</summary>" >>"$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#Need Add an empty line to validate details
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#close the details tag
echo "</details>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#Need Add an empty line to validate details
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#Add a details tag : ACTION
echo "<details style=\"border: 1px #ffffff; outline: solid; display: inline-block;\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  <summary style=\"border: 1px #ffffff; outline: solid; cursor: pointer; \">Actions</summary>" >>"$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#Need Add an empty line to validate details
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#ADD ACTIONS
echo "Properties <span>0</span> files and <span>0</span> folders selected. Total size : <span></span>. Last modified : <span></span>.<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#echo "<input class='_bt_download' type='button' value='Download'><br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<input class='_bt_makeZip' type='button' value='Make a zip'><br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#close the details tag
echo "</details>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
#Need Add an empty line to validate details
echo "  " >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "<br>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"