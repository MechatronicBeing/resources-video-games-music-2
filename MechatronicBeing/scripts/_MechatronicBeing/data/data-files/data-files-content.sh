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

#the path to fileIcon dir and the sub-folder (format)
read -r fileIconDir fileIconSizeDir  <<< $($currentScriptDir/$globalValuesScriptname  "fileIconDir" "fileIconSizeDir")

#Get other values
read -r targetDir spaceEscape spacerValue repositoryDirAdjust repositoryDirChange repositoryFileChange pagesFilesIconsDir pagesFilesIconsExt spacerTimes <<< $($currentScriptDir/$globalValuesScriptname "pagesFilesTargetDir" "escapeSpacesInUrl" "htmlSpacer" "repositoryDirAdjust" "repositoryDirChange" "repositoryFileChange" "pagesFilesIconsDir" "pagesFilesIconsExt" "spacerTimes")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
#Add 1 more folder : for Root
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir" 1)
#Used for images 
showedRelativeCategoryTarget=$($executeFindRelativePathScriptname "$targetDir")

#Variables for main Identifier AND location used for the search
mainItemId="${categoryName}/"
mainLocation="${categoryName}/"
#The git path (o avoid)
gitPath="${mainLocation}.git"

#change to ROOT directory
cd "$rootPath"

#Show current directory
echo "(${currentScript##*/}) CREATING LIST OF FILES FOR '$categoryName'"

#Create data directory (if not exist)
if [[ ! -d "$categoryPath/$dataPath" ]]; then
  mkdir -p "$categoryPath/$dataPath"
fi

#Array for save locations in progress (to show files later)
declare -a locationsInProgress=()
#Array for identifying each location
declare -A locationIdentifier
#Array with elements (dirs and files) counter for a location
declare -A directoryElementCounter

#A variable for the current line number FOR odd/even class color
currentNumLine=0

#Create the Datafiles
:> "$categoryPath/$dataPath/$dataFilesRawfile"
:> "$categoryPath/$dataPath/$dataFilesMDfile"
:> "$categoryPath/$dataPath/$dataFilesHTMLfile"

#Create the -special!- JS datafile 
rowParameterNameInJSFunction="aRow"
insertCellLine=""
for((i=0;i<8;i++)); do 
  insertCellLine="${insertCellLine}${rowParameterNameInJSFunction}.insertCell();"
done
functionNameInJS="${categoryName//-/_}"
echo "function insertAllCells(${rowParameterNameInJSFunction}){ ${insertCellLine} }" > "$categoryPath/$dataPath/$dataFilesJSfile"
echo "function ${functionNameInJS}_writeData(){" >> "$categoryPath/$dataPath/$dataFilesJSfile"
echo "var currentTbody = document.getElementById('tb_${categoryName}_');" >> "$categoryPath/$dataPath/$dataFilesJSfile"
echo "var currentRow;" >> "$categoryPath/$dataPath/$dataFilesJSfile"

#Create spacer depending on the path (in $1) level
addSpacer()
{
  #Get fullPath
  fullPath="$1"
  #If the path end with /, remove it !!! used only fore files !!
  if [[ "${itemName:$((${#itemName}-1)):1}" == "/" ]]; then
    #remove '/'
    fullPath="${fullPath%/}"
  fi
  #Create a simplePath with '/' only (remove all other chars)
  simplePath="${fullPath//[^\/]/}"
  #Create spacers
  dirLevel=$((${#simplePath}))
  dirSpacer=""
  for((i=0;i<"$dirLevel";i++)); do 
    for(( j=0; j<"$spacerTimes"; j++)); do
      dirSpacer="${dirSpacer}${spacerValue}"
    done
  done
  echo "$dirSpacer"
}

#Function  return a path to a icon according to file extension ($1)
getFileIcon() {
  #Get filename
  fileExtension="$1"
  iconChoice=""

  #If the last character is "/", the "file" is a folder !
  if [[ "${fileExtension}" == "/" ]]; then
    iconChoice="places/folder.png"
  else
    #Depending of the file extension, found the icon.
    if [[ "${fileExtension}" == "MP3" ]]; then
      iconChoice="mimetypes/audio-x-generic.png"
    elif [[ "${fileExtension}" == "MP4" ]]; then
     iconChoice="mimetypes/video-x-generic.png"
    elif [[ "${fileExtension}" == "JPG" || "${fileExtension}" == "JPEG" || "${fileExtension}" == "PNG" ]]; then
      iconChoice="mimetypes/image-x-generic.png"
    elif [[ "${fileExtension}" == "ZIP" || "${fileExtension}" == "GZ" ]]; then
      iconChoice="mimetypes/package-x-generic.png"
    elif [[ "${fileExtension}" == "HTML" || "${fileExtension}" == "HTM" ]]; then
      iconChoice="categories/applications-internet.png"
    elif [[ "${fileExtension}" == "TXT" || "${fileExtension}" == "MD" ]]; then
      iconChoice="apps/accessories-text-editor.png"
    elif [[ "${fileExtension}" == "SH" ]]; then
      iconChoice="mimetypes/text-x-script.png"
    elif [[ "${fileExtension}" == "EXE" ]]; then
      iconChoice="mimetypes/application-x-executable.png"
    else
      iconChoice="mimetypes/text-x-generic-template.png"
    fi
  fi
    
  #Return the path to the icon
  echo "${fileIconDir}/${fileIconSizeDir}/${iconChoice}"
}

#Show the information
showLineInformation()
{ 
  #Get information
  itemId="$1"
  itemSize="$2"
  itemLastModification="$3"
  itemFilesNumber="$4"
  itemFoldersNumber="$5"
  itemLocation="$6" #with a / at the end
  itemName="$7" #if '/' at the end : folder, else file
  itemIsSelectable="$8"
  itemIsCounted="$9"
    
  #GetItemLocation space escaped !
  itemFullPath="${itemLocation}${itemName}"
  itemLocationProtected="${itemLocation// /$spaceEscape}"
  itemFullPathProtected="${itemFullPath// /$spaceEscape}"
  
  #If the last char is '/' it's a directory)
  if [[ "${itemName:$((${#itemName}-1)):1}" == "/" ]]; then
    #Type is 'Folder'
    showedItemFileExtField="Folder"
    #Get dirname without / and extension is '/'
    itemNameWithoutExt="${itemName%/}"
    itemFileExt="/" #an exception : only folder can get a '/' extension !
    showedItemFileExt="$itemFileExt"
    showedItemFilesNumber="$itemFilesNumber"
    showedItemFoldersNumber="$itemFoldersNumber"
    #For raw data file : use the same values
    showedRAWItemFilesNumber="$showedItemFilesNumber"
    showedRAWItemFoldersNumber="$showedItemFoldersNumber"
  else
    #Get Filename without extension and get extension
    itemNameWithoutExt="${itemName%.*}"
    #If the file had NO extension ('.')
    if [[ "$itemNameWithoutExt" == "$itemName" ]]; then
      itemFileExt=""
      showedItemFileExt="$itemFileExt"
      showedItemFileExtField="File"
    else
      #get extension
      itemFileExt="${itemName##*.}"
      showedItemFileExt=".${itemFileExt}" #add an . in the extension
      #uppercase the file type
      showedItemFileExtField="File:${itemFileExt^^}"
    fi
    #Files don't have files and folder inside them, leave a empty field
    showedItemFilesNumber=""
    showedItemFoldersNumber=""
    #Replace with true value
    showedRAWItemFilesNumber="1"
    showedRAWItemFoldersNumber="0"
  fi
  
  #Get the file icon
  fileIconPath=$(getFileIcon "${itemFileExt^^}")
  
  #######################################################################################################
  #FOR MD FILES
  
  #Prepare File icon (used in MD file)
  showedMDItemIcon="<img class=\"file-icon\" style=\"height: 22px;\" src=\"${showedRelativeCategoryTarget}/${fileIconPath}\"/>"
  
  #if the item is a folder
  if [[ "$itemFileExt" == "/" ]]; then
    #Remove the first folder (the current category name) in the location
    repositoryChange="${categoryName}/${repositoryDirChange}/${itemFullPathProtected#*/}"
  else
    #Remove the first folder (the current category name) in the location
    repositoryChange="${categoryName}/${repositoryFileChange}/${itemFullPathProtected#*/}"
  fi
  
  #If the location is empty : it's the main folder ! empty the repositorychange and restore the $itemFullPathProtected
  if [[ "$itemLocation" == "" ]]; then
    repositoryChange="$itemFullPathProtected"
  fi
  
  showedMDItemLink="<a class=\"file-link\" href=\"${showedRelativeFinalTarget}/${repositoryDirAdjust}/${repositoryChange}\" style='text-decoration: none; border-spacing: 0; border-width: 0;'>${showedMDItemIcon}${spacerValue}${itemNameWithoutExt}<span class=\"_fileExtension\">${showedItemFileExt}</span></a>"
    
  ######################################################################
    
  #Prepare File icon (used in HTML files)
  showedHTMLItemIcon="<img class=\"file-icon\" src=\"${showedRelativeCategoryTarget}/${fileIconPath}\"/>"
    
  showedHTMLItemLink="<a class=\"file-link\" href=\"${showedRelativeFinalTarget}/${itemFullPathProtected}\" >${showedHTMLItemIcon}${spacerValue}<span class=\"file-link-element\">${itemNameWithoutExt}</span><span class=\"_fileExtension file-link-element\">${showedItemFileExt}</span></a>"
  showedHTMLCheckbox="<input class=\"file-selector\" type=\"checkbox\" id=\"cb_${itemId}_\"  data-file=\"${showedRelativeFinalTarget}/${itemFullPathProtected}\" data-path=\"${itemLocationProtected}\" data-ext=\"$itemFileExt\" data-size=\"$itemSize\" data-numFiles=\"$itemFilesNumber\" data-numFolders=\"$itemFoldersNumber\" data-lastModif=\"$itemLastModification\" onclick=\"changeCheckedItems('${itemId}');\"/>"
 
  #variable for human-readable file size
  showedSize=$(numfmt --to=iec $itemSize)
  
  #Create a spacer for the item
  itemSpacer=$(addSpacer "$itemFullPathProtected")
  
  itemHashIntegrity="-"
 
  #If the item is not selectable, modify the values
  if [[ "$itemIsSelectable" -eq O ]]; then
    showedMDItemLink="${showedHTMLItemIcon}${itemName}"
    showedHTMLItemLink="${showedHTMLItemIcon}${itemName}"
    #get the showedHTMLCheckbox without the > end character
    modifiedShowedHTMLCheckbox="${showedHTMLCheckbox%\>}"
    #modify the html checkbox to be disabled
    showedHTMLCheckbox="${modifiedShowedHTMLCheckbox} disabled=\"true\" >"
  fi
  
  #If folder : strong the link
  if [[ "$itemFileExt" == "/" ]]; then
    showedMDItemLink="**$showedMDItemLink**"
    showedHTMLItemLink="<strong>$showedHTMLItemLink</strong>"
  fi
  
  #If the item is not counted
  if [[ "$itemIsCounted" -eq 0 ]]; then
    showedMDItemLink="${showedMDItemLink}"
    showedHTMLItemLink="${showedHTMLItemLink}"
    itemLastModification="${itemLastModification}"
    showedItemFileExtField="${showedItemFileExtField}"
    showedSize="${showedSize}"
    showedItemFilesNumber="${showedItemFilesNumber}"
    showedItemFoldersNumber="${showedItemFoldersNumber}"
  fi
  
  #Write information in a RAW file (like 'du' or 'ls' format)
  echo "$itemSize $itemLastModification $showedItemFileExtField $showedRAWItemFilesNumber $showedRAWItemFoldersNumber $itemHashIntegrity $itemFullPath" >> "${categoryPath}/${dataPath}/${dataFilesRawfile}"

  #Write information in a MD file
  echo "| ${itemSpacer}${showedMDItemLink} | $itemLastModification | $showedItemFileExtField | $showedSize | $showedItemFilesNumber | $showedItemFoldersNumber | $itemHashIntegrity |  " >> "${categoryPath}/${dataPath}/${dataFilesMDfile}"

  #Get the classname (color of the row)
  if [[ $((currentNumLine%2)) -eq 0 ]]; then
    className="even"
  else
    className="odd"
  fi
  
  #Prepare the html data (fields)
  dataOuterHTML=()
  dataOuterHTML[0]="<td class=\"file-cell-0 file-cell-text\">${showedHTMLCheckbox}</td>"
  dataOuterHTML[1]="<td class=\"file-cell-1 file-cell-text\">${itemSpacer}${showedHTMLItemLink}</td>"
  dataOuterHTML[2]="<td class=\"file-cell-2 file-cell-text\">${itemLastModification}</td>"
  dataOuterHTML[3]="<td class=\"file-cell-3 file-cell-text\">${showedItemFileExtField}</td>"
  dataOuterHTML[4]="<td class=\"file-cell-4 file-cell-number\">${showedSize}</td>"
  dataOuterHTML[5]="<td class=\"file-cell-5 file-cell-number\">${showedItemFilesNumber}</td>"
  dataOuterHTML[6]="<td class=\"file-cell-6 file-cell-number\">${showedItemFoldersNumber}</td>"
  dataOuterHTML[7]="<td class=\"file-cell-7 file-cell-text\">${itemHashIntegrity}</td>"
  lineHTML=""
  
  #Add a new row to the tbody
  echo "currentRow = document.getElementById('tr_${itemId}_');" >> "$categoryPath/$dataPath/$dataFilesJSfile"
  echo "if (currentRow === null) { " >> "${categoryPath}/${dataPath}/${dataFilesJSfile}"
  echo "  currentRow = currentTbody.insertRow(-1);" >> "${categoryPath}/${dataPath}/${dataFilesJSfile}" 
  echo "  currentRow.id = 'tr_${itemId}_';" >> "${categoryPath}/${dataPath}/${dataFilesJSfile}" 
  echo "  currentRow.class = 'file-row ${className}';" >> "${categoryPath}/${dataPath}/${dataFilesJSfile}" 
  echo "  insertAllCells(currentRow);" >> "${categoryPath}/${dataPath}/${dataFilesJSfile}" 
  echo "} " >> "${categoryPath}/${dataPath}/${dataFilesJSfile}"
  
  #Write information into HTML file
  for((i=0;i<${#dataOuterHTML[@]};i++)); do 
    #escape the double quote
    escapeDQuotes="${dataOuterHTML[$i]//\"/\\\"}"
    
    #add the information in the js file
    #Need to escape the double quote in the js file !
    echo "currentRow.cells[$i].outerHTML = \"${escapeDQuotes}\";" >> "${categoryPath}/${dataPath}/${dataFilesJSfile}"
    
    #add the information to the html file
    #Note : don't escape double quoted
    lineHTML="${lineHTML}${dataOuterHTML[$i]}"
  done
  
  #Write the full line in the HTML file
  echo "<tr id=\"tr_${itemId}_\" class=\"file-row ${className}\">${lineHTML}</tr>" >> "${categoryPath}/${dataPath}/${dataFilesHTMLfile}"
  
  #Increment currentNumLine (for odd/even)
  currentNumLine=$(($currentNumLine+1))
}

#Show the files of last locations, if needed (changes between a new location -$1- and the previous locations)
getFilesInformation()
{
  #Get the new path with the $1
  newpath="$1"

  #Loop to show the files
  while :; do
    lastIndexLocationsInProgress=$((${#locationsInProgress[@]}-1))
    #If the directories array is not empty
    if [[ "$lastIndexLocationsInProgress" -ge 0 ]]; then
      #Get the last element in the array
      lastLocation="${locationsInProgress[$lastIndexLocationsInProgress]}"
      #If the new directory NOT start like the last location
      if ! [[ "$newpath" =~ ^"$lastLocation" ]]; then
        #Get all files of the the last location with find+du
        #find -maxdepth 1 : no sub-directories (only the "$lastLocation")
        #find -type f : only files
        #find -exec : for each result (line), execute the next command with the result
        #du --time : show datetime of last modification (very useful)
        #du -B1 : real size value -not human readable-
        #du --exclude : exclude the git folder (else it will be added and fake the -size- results)
        #note : du results use '\t' between each field, use IFS=$'\t' to read the fields
        find "$lastLocation" -maxdepth 1 -type f -exec du --time -B1 --apparent-size --exclude="$gitPath" {} + | while IFS=$'\t' read -r sizeFile datetimeOfLastModifFile filepath; do
          #Get filename 
          filename="${filepath##*/}"
          #Get the file location
          fileLocation="${filepath%/*}/"
          
          #Increment the elementCounter in the location
          directoryElementCounter["$fileLocation"]=$((${directoryElementCounter["$fileLocation"]}+1))
          
          #Create the fileItemID (from locationID + currentElement in the location)
          fileItemId="${locationIdentifier[$fileLocation]}${directoryElementCounter[$fileLocation]}"
          
          #show the information
          showLineInformation "$fileItemId" "$sizeFile" "$datetimeOfLastModifFile" "1" "0" "${fileLocation}" "${filename}" 1 1
        done
        #Remove the last location in progress
        unset locationsInProgress[$lastIndexLocationsInProgress]
      else
        #The new directory is IN the previous location, 
        #exit the while
        break
      fi
    else
      #the directory array is empty : break the while
      break
    fi
  done
}

#Get all directory
#du --time : show datetime of last modification (very useful)
#du -B1 : real size value -not human readable-
#du --exclude : exclude the git folder (else it will be added and fake the -size- results)
#sort -f : insensitive case (uppercase/lowercase not important)
#sort -k4 : sort the 4 field/column -the paths- 
du --time -B1 --apparent-size --exclude="$gitPath" "$categoryName" | sort -f -k4 > "$rootPath/${categoryName}_dirs.tmp"

#note : du results use '\t' between each field, use IFS=$'\t' to read the fields
while IFS=$'\t' read -r size datetimeOfLastModif dirpath; do 

  #Test if path exist (can be removed)
  if [[ -e "$dirpath" ]]; then
  
    #get the dirname
    currentDirname="${dirpath##*/}"
    
    #get previous path
    location="${dirpath%/*}/"
   
    #If the current path IS the root path (category)
    if [[ "$dirpath" == "$categoryName" ]]; then
      #Set with main itemID
      itemId="$mainItemId"
      #set the previous path to empty
      location=""
    else
      #Increment the element counter of the previous path
      directoryElementCounter["$location"]=$((${directoryElementCounter["$location"]}+1))
      #Get the itemID (from the previous path id + number of element of the previous path
      itemId="${locationIdentifier[$location]}${directoryElementCounter[$location]}/"
    fi
    
    #Add a / at the end of dirpath
    dirpath="${dirpath}/"
    
    #Initialize the locationIdentifier for the current path
    locationIdentifier["$dirpath"]="$itemId"
    #set 0 the element counter of the current path
    directoryElementCounter["$dirpath"]=0
    
    #Show the files of previous location (if needed)
    getFilesInformation "$dirpath"
    
    #Count all directories founded in the current directory (NOT .git/ and NOT under .git/*)
    dirsNumber=$((`find "$dirpath" -mindepth 1 -type d -not -path "$gitPath" -not -path "$gitPath/*" | wc -l`))
       
    #Count all files founded in the current directory
    filesNumber=$((`find "$dirpath" -type f -not -path "$gitPath/*" | wc -l`))
    
    #show the information
    showLineInformation "$itemId" "$size" "$datetimeOfLastModif" "$filesNumber" "$dirsNumber" "$location" "${currentDirname}/" 1 1
    
    #Add the current directory to the list
    locationsInProgress+=( "$dirpath" )

  fi
done < "$rootPath/${categoryName}_dirs.tmp"

#Show the files in the remaining location 
#parameter "" is a fake location, to force all remaining locations to get treated
getFilesInformation ""

#Finish the JS function
echo "}" >> "$categoryPath/$dataPath/$dataFilesJSfile"

#Remove the temporary file
rm "$rootPath/${categoryName}_dirs.tmp"
