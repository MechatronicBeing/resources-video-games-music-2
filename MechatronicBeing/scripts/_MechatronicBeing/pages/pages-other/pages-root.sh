#Create the readme.md at the root directory

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
#Get parameters
read -r targetDir rootMDfilename dataPath rootTemplateFilename mainCategory <<< $($currentScriptDir/$globalValuesScriptname  "rootPagesDirname" "rootMDfilename" "dataPath" "rootTemplateFilename" "mainCategoryName")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#Show message
echo "(${currentScript##*/}) CREATING ROOT PAGE FOR '$categoryName'"

#Create an empty rootMD file
:> "${categoryPath}/${targetDir}/${rootMDfilename}"

# Write the line in the file
if [[ -e "${categoryPath}/${dataPath}/${rootTemplateFilename}" ]]; then

  while IFS= read -r currentLine || [[ -n "$currentLine" ]]; do
    #remove the \r at the end (else, the line can be 'corrupted')
    currentLine="${currentLine%$'\r'}"
    
    #the sub-string to analyse
    currentSubStringToReplace="$currentLine"
    
    #Try to extract the first parameter
    extractBeforeParam="${currentSubStringToReplace%%\$\$*}"
    
    #Loop until the string to analyse is empty OR the string to analyse + the extracted string are the same (=no others parameters founded)
    while [[ "$currentSubStringToReplace" != "" && "$extractBeforeParam" != "$currentSubStringToReplace" ]]; do 
      #Got a first $$, extract the name
      extractParamName="${extractBeforeParam%%\$\$*}"
      
      #Remove the currentParameter founded.
      currentSubStringToReplace="${currentSubStringToReplace#*\$\$}"
      
      #Get the global value
      value=$($currentScriptDir/$globalValuesScriptname  "${extractParamName}")
      
      #Replace the $$name$$ in the current (full) line
      currentLine="${currentLine//\$\$${extractParamName}\$\$/${value}}"
       
      #Replace the parameter founded in the current working line
      currentSubStringToReplace="${currentSubStringToReplace//\$\$${extractParamName}\$\$/${value}}"
      
      #Try to extract the next parameter
      extractBeforeParam="${currentSubStringToReplace%%\$\$*}"
    done
    
    #Write the new string (replaced the parameters) in the file
    echo "$currentLine" >> "${categoryPath}/${targetDir}/${rootMDfilename}"
    
  done < "${categoryPath}/${dataPath}/${rootTemplateFilename}"
fi
