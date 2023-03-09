#Create content for pages-files

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
read -r dataPath dataFilesHeaderPrefix  dataFilesMDfile dataFilesHTMLfile dataFilesJSfile <<< $($currentScriptDir/$globalValuesScriptname "filesDataPath" "dataFilesHeaderPrefix" "dataFilesMDfile"  "dataFilesHTMLfile" "dataFilesJSfile")
#Get the others values
read -r targetDir pagesFilesMDFilename pagesFilesHTMLFilename <<< $($currentScriptDir/$globalValuesScriptname "pagesFilesTargetDir" "pagesFilesMDFilename" "pagesFilesHTMLFilename")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
#Add one folder more : the root folder
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir" 1)

filenames=("$pagesFilesMDFilename" "$pagesFilesHTMLFilename")
filesContent=("$dataFilesMDfile" "$dataFilesHTMLfile")

#change to category directory
cd "$rootPath"

#Create target directory (if not exist)
if [[ ! -d "$categoryPath/$targetDir" ]]; then
  mkdir -p "$categoryPath/$targetDir"
fi

#Show message
echo "((${currentScript##*/})) CREATING CONTENT-PAGE OF FILES FOR '$categoryName'"

echo "<table>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

for (( i=0; i<${#filenames[@]}; i++)); do

  if [[ "${filenames[$i]}" != "$pagesFilesHTMLFilename" ]]; then
    #if the HEADER exist, append it to the md file
    if [[ -f "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${filesContent[$i]}" ]]; then
      cat "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${filesContent[$i]}" >> "$categoryPath/$targetDir/${filenames[$i]}"
    fi
  fi

  #For each directory, starting with the same name
  for D in $categoryName*; do
  
    #If D is a directory
    if [[ -d "$D" ]]; then
    
      #If the current loop is the html page
      if [[ "${filenames[$i]}" == "$pagesFilesHTMLFilename" ]]; then        
        #if the HEADER exist, append it to the file
        if [[ -f "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${filesContent[$i]}" ]]; then
          cat "$categoryPath/$dataPath/${dataFilesHeaderPrefix}${filesContent[$i]}" >> "$categoryPath/$targetDir/${filenames[$i]}"
        fi
        
        #HTML : Add a specific tbody, inside the table, for the directory
        echo "  <tbody id=\"tb_${D}_\">" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
      fi
      
      #If D folder IS the current category : show all the files
      if [[ "$D" == "$categoryName" ]]; then
        if [[ -e "$categoryPath/$dataPath/${filesContent[$i]}" ]]; then
          cat "$categoryPath/$dataPath/${filesContent[$i]}" >> "$categoryPath/$targetDir/${filenames[$i]}"
        fi
      else
        #else, if a file content exist
        if [[ -e "$D/$dataPath/${filesContent[$i]}" ]]; then
          #Read the first line
          read -r line < "$D/$dataPath/${filesContent[$i]}"
          #remove the \r at the end (else, the line can be 'corrupted')
          line="${line%$'\r'}"
          
          #Add the line to the tbody
          echo "$line" >> "$categoryPath/$targetDir/${filenames[$i]}"
          
          #Add a line with a button to load external data
          functionNameInJS="${D//-/_}"
          echo "<tr><td colspan='8'><input id=\"bt_load_$D_\" type=\"button\" value=\"LOAD DATA\" onclick=\"loadData('$showedRelativeFinalTarget/$D/$dataPath/$dataFilesJSfile', '${functionNameInJS}_writeData');\" /></td></tr>" >> "$categoryPath/$targetDir/${filenames[$i]}"
        else
          line=""
          #Add the line to the tbody
          echo "$line" >> "$categoryPath/$targetDir/${filenames[$i]}"
        fi
      fi
      
      #If the current loop is the html page
      if [[ "${filenames[$i]}" == "$pagesFilesHTMLFilename" ]]; then
        #HTML : End the tbody tag
        echo "  </tbody>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
      fi
    fi
  done

done

#HTML : end the line of the table
echo "</table>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"