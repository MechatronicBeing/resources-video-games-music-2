# Create files with lines related for each directories starting with a same name

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
#Get parameters
read -r targetDir repositoryDir mainCategoryDir mainCategoryName homeCategory   <<< $($currentScriptDir/$globalValuesScriptname  "pageListDir" "repositoryDirAdjust" "mainCategoryDir" "mainCategoryName" "homeCategory")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
#Add 1 more folder : the final folder (not indicated)
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir" 1)

#The 2 md files
mdFiles=("readme.md.tmp" "index.md.tmp")

#change to root directory
cd "$rootPath"

# Create target directory (if not exist)
if [[ ! -e "$rootPath/$categoryName/$targetDir/" ]]; then
  mkdir -p "$rootPath/$categoryName/$targetDir/"
fi

#Show message
echo "(${currentScript##*/}) CREATING LIST FOR '$categoryName'"

#Write header for the 2 filename (no difference)
for mdFile in ${mdFiles[@]}; do
  #Prepare files (with a first line)
  echo "## List of \"$categoryName\"  " > "$rootPath/${categoryName}_list_${mdFile}"
done

#For each directory, with a name starting with the category
for D in $categoryName*; do
          
  #If it's a directory
  if [[ -d "$D" ]]; then
                 
    #simplify the name (remove the start)          
    showedNameCategory="${D#$categoryName-}"
          
    # Write lines in files
    echo "[$showedNameCategory]($showedRelativeFinalTarget/$repositoryDir/$D/)  " >> "$rootPath/${categoryName}_list_readme.md.tmp"
    echo "[$showedNameCategory]($showedRelativeFinalTarget/$D/)  " >> "$rootPath/${categoryName}_list_index.md.tmp"
  fi
done

#Write header for the 2 filename (no difference)
for mdFile in ${mdFiles[@]}; do
  #Add a details tag (for showing or not the other categories)
  echo "<details style=\"border: 1px #ffffff; outline: dashed; display: inline-block;\">" >> "$rootPath/${categoryName}_list_${mdFile}"
  echo "  <summary style=\"border: 1px #ffffff; outline: dashed; cursor: pointer; \">Other ${mainCategoryName}</summary>" >> "$rootPath/${categoryName}_list_${mdFile}"
  #Need Add an empty line to validate details
  echo "  " >> "$rootPath/${categoryName}_list_${mdFile}"
done

# SHOW THE OTHERS RESOURCES (not with $categoryName !)
#For each directory, with a name starting with the category
for D in $mainCategoryDir*; do
          
  #If it's a directory
  if [[ -d "$D" ]]; then
    
    #If the Dir is not the current directory name (because this operation is already done before)
    if ! [[ "$D" =~ ^$categoryName  ]]; then
    
      #simplify the name (remove the start)          
      showedNameCategory="${D#${mainCategoryDir}-*}"
      if [[ "$D" == "$mainCategoryDir" ]]; then
        showedNameCategory="$homeCategory"
      fi
          
      # Write lines in files
      echo "[$showedNameCategory]($showedRelativeFinalTarget/$repositoryDir/$D/)  " >> "$rootPath/${categoryName}_list_readme.md.tmp"
      echo "[$showedNameCategory]($showedRelativeFinalTarget/$D/)  " >> "$rootPath/${categoryName}_list_index.md.tmp"
    fi
  fi
done

#Write headers for the 2 filename (no difference)
for mdFile in ${mdFiles[@]}; do
  #close the details tag
  echo "</details>" >> "$rootPath/${categoryName}_list_${mdFile}"
  #Need Add an empty line to validate details
  echo "  " >> "$rootPath/${categoryName}_list_${mdFile}"
  
  #Move the temp file to the target (and rename it)
  mv "$rootPath/${categoryName}_list_${mdFile}" "$rootPath/$categoryName/$targetDir/${mdFile%.tmp}"
done

