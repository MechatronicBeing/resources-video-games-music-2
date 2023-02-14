#Create README.md AND INDEX.HTML, with a listing of ALL files and directories of the current dir
#Note : index.html differ from readme because of Downloading option
#Why ? Inputs/checkboxes are erased from the tables (with a markdown to html converter...)
#Readme is preserved for the online repository...

#the target Directory (FROM THE CATEGORY DIR) (for md files)
targetDir="MechatronicBeing/pages/downloading/files"

#the Zip script target
zipScriptTarget="MechatronicBeing/scripts/web/zip"

#DETAILED (special) : the data savefile path
dataSaveDir="MechatronicBeing/pages/downloading/files"
#DETAILED (special) : the data savefile name 
dataFileName="files.dat"

#The index.html (temp)
#using html because of checkbox in tables
htmlFile="index.html.tmp" 
mdFile="readme.md.tmp"

#In case of names with spaces, replace the " " with "%20"
spaceEscape="%20"

#Spacer 
spacerValue="&nbsp;"

#the (root) category -RELATIVE- directory (containing the FILES) used for search
#Read the information in the global file
categoryDir=$(cat "../_variables/categoryPath.txt")

#keep the current script directory 
currentScriptDir=`pwd`

#track back previous folder to found the last directory, BEFORE the categoryDir (=the last ..)
path="$currentScriptDir" 
down="$categoryDir"
while :; do
  test "$down" = '..' && break
  path="${path%/*}"
  down="${down%/*}"
done
#Remove the last '..' to get the category path (full)
categoryFullDir="${path%/*}"
#Take only the final folder
categoryName="${categoryFullDir##*/}"
#Take the root path
rootPath="${categoryFullDir%/*}"

#the root -RELATIVE- directory used IN the final page [CALCULATED from the target dir]
#Get all the '/' (remove all others characters) in path
showedCategoryDir=`echo "$targetDir" | tr -cd /`
#Add .. for each / (and add one at the beginning)
showedCategoryDir="..${showedCategoryDir//\//\/..}"

#set variables
fileNameFull=""
dirSpacer=""
fileNameProtected=""
fileSpacer=""
sizeGit=0
lastGitUpdate=""
previousFilename="."
previousDirLevelId=0
dirArray=(1)
fileIdentifier=""

#Create data save directory (if not exist)
if [[ ! -d "$categoryFullDir/$dataSaveDir" ]]; then
  mkdir -p "$categoryFullDir/$dataSaveDir"
fi

#Title
htmlTitle="List of files and directories in '$categoryName'"

#change to category directory
cd "$categoryDir"

#Show current directory
echo "[$0] ANALYSIS OF FILES IN '$categoryName'"
  
#HTML FILE HEADER
echo "<!DOCTYPE html>" > "$rootPath/$htmlFile"
echo "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"\" xml:lang=\"\">" >> "$rootPath/$htmlFile"
echo "<head>" >> "$rootPath/$htmlFile"
echo "  <meta charset=\"utf-8\" />" >> "$rootPath/$htmlFile"
echo "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=yes\" />" >> "$rootPath/$htmlFile"
echo "  <title>$htmlTitle</title>" >> "$rootPath/$htmlFile"
echo "</head>" >> "$rootPath/$htmlFile"
echo "<body>" >> "$rootPath/$htmlFile"
echo "<h2>$htmlTitle</h2>" >> "$rootPath/$htmlFile"
echo "<p><em>Date : $(date +%F)</em><br />" >> "$rootPath/$htmlFile"
echo "<em>Note : actual values may vary !</em></p>" >> "$rootPath/$htmlFile"
echo "  " >> "$rootPath/$htmlFile"
echo "<table>" >> "$rootPath/$htmlFile"
echo "<tr><th>Name</th><th>Directories</th><th>Files</th><th>Size</th><th>Download</th></tr>" >> "$rootPath/$htmlFile"

#MD FILE HEADER
echo "## $htmlTitle  " > "$rootPath/$mdFile"
echo "*Date : $(date +%F)*  " >> "$rootPath/$mdFile"
echo "*Note : actual values may vary !*  " >> "$rootPath/$mdFile"
echo "  " >> "$rootPath/$mdFile"
echo "| **Name** | **Directories** | **Files** | **Size** |  " >> "$rootPath/$mdFile"
echo "| -------- | --------------- | --------- | -------- |  " >> "$rootPath/$mdFile"


#Get all files/directory with du
#-a (all files/dir) --apparent-size (important, the "general" size) --exclude git | sort by filename (Alpha)
du -a -B1 --apparent-size . --exclude=".git" | sort -k2 > "$rootPath/$categoryName.files.tmp"
while read line; do 
  
  #Get the size   
  size=`echo $line | cut -d' ' -f1`
  #variable for human-readable file size
  showedSize=$(numfmt --to=iec $size)
  
  #Remove the substring from start to . (used in 'du' command)
  fileName="${line#*.}"
  #Remove the / at start
  fileNameFull="${fileName#*/}"
  
  #If filename is empty (root), use the '.'
  if [[ "$fileNameFull" == "" ]]; then
    fileNameFull='.'
  fi
  
  #PROTECT fileName containing SPACES (replace ' ' with '%20')
  fileNameProtected="${fileNameFull// /$spaceEscape}"
  
  #Shorten the filename
  showedFileName="${fileNameFull##*/}"
  
  #Add spacers (also used by file)
  dirLevel=$((`echo "$fileNameFull" | tr -cd / | wc -c`))
  dirSpacer=""
  for((i=0;i<"$dirLevel";i++)); do 
    dirSpacer="$dirSpacer$spacerValue$spacerValue"
  done
  
  ##################################################################
  # Create an unique identifier for directories/files in a list
  # Work as title/chapters/sub-chapters/... in a book
  # VERY useful for selecting specific folders+files (with sub-folders and files included) or all the files...
  #
  # # EXEMPLE :
  # .                 id: 1
  # abc/              id: 1.1
  # abc/1.txt         id: 1.1.1
  # abc/2.jpg         id: 1.1.2
  # def/              id: 1.2
  # def/ghi/          id: 1.2.1
  # def/ghi/jkl/      id: 1.2.1.1
  # def/ghi/jkl/3.md  id: 1.2.1.1.1
  # def/ghi/jkl/4.md  id: 1.2.1.1.2
  # def/mno/          id: 1.2.2
  # def/5.html        id: 1.2.3
  # mno/              id: 1.3
  # mno/6.wav         id: 1.3.1 
  # pqr/              id: 1.4  
  # pqr/abc/          id: 1.4.1
  #
  # if select 1, then all the files is selected
  # if select 1.1, then 1.1 + 1.1.1 + 1.1.2 are selected (the 'abc' folder with '1.txt' and '2.jpg' files inside).
  # if select 1.2.1.1, then 1.2.1.1 + 1.2.1.1.1 + 1.2.1.1.2 are selected, but NOT the other folder in the other section (1.2.2 and 1.2.3) 
  
  
  #Get variables (filenames could be files or dir)
  prevDir="$previousFilename/" 
  newDir="$fileNameFull/"
  dirLevelId=1
  
  while :; do
    #Get the first directory
    firstPrevDir="${prevDir%%/*}"
    firstNewDir="${newDir%%/*}"
    
    if [[ "$firstPrevDir" != "$firstNewDir" || "$firstPrevDir" == "" || "$firstNewDir" == "" ]] ; then
      #If folders are different, or one folder is empty (end), break the loop
      break
    else
      #Remove the same root Dir, move forward in the paths
      prevDir="${prevDir#*/}"
      newDir="${newDir#*/}"
      dirLevelId=$(($dirLevelId+1))
    fi
  done
  
  #Increment the current index
  dirArray[$dirLevelId]=$((${dirArray[$dirLevelId]}+1))
  #get the max dir = the remaining '/' + the current dirLevelId
  maxdirLevelId=$((`echo "$newDir" | tr -cd / | wc -c`+$dirLevelId))
  #for the next index to remaining level in the , set to 1
  for ((i = $dirLevelId+1 ; i < $maxdirLevelId ; i++ )); do
    dirArray[$i]=1
  done
  
  #If the previous level was higher than the current level dir (max), reset to 0 the rest for next use
  for ((i = $maxdirLevelId ; i < $previousDirLevelId ; i++ )); do
    dirArray[$i]=0
  done
  
  #Create the file identifier, by concatenation of dirArray values
  #Note : AVOID looping with the root category '.' or else it will print a '1.' -1 needed-
  fileIdentifier="${dirArray[0]}"
  if [[ "$fileNameFull" != "." ]]; then
    for ((i=1 ; i < $maxdirLevelId ; i++ )); do
      fileIdentifier="${fileIdentifier}.${dirArray[$i]}"
    done
  fi
  
  #Save the current filename and dirLevel for the next comparison
  previousFilename="$fileNameFull"
  previousDirLevelId=$maxdirLevelId
  
  #
  ################################END OF THE unique identifier for directories/files in a list
  
  #If directory exist
  if [[ -d "$fileNameFull" ]]; then
  
    #If root AND '.git' directory exist
    if [[ "$fileNameFull" == "." && -d ".git" ]]; then
      #Get size of the .git directory
      sizeGit=`du -B1 -s ".git" --apparent-size | cut -f1`
      
      #Get the date of the last commit (with the git command)
      lastGitUpdate=`git --git-dir "$categoryFullDir/.git" log -1 --pretty=format:"%ad" --date=short`
      
      #Count all directories founded in the current directory 
      #exclude the '.git' (but decrement 1 as '.git' dir is counted)
      directoriesC=$((`find . -mindepth 1 -type d -not -path './.git/*' | wc -l`-1))
     
      #Count all files founded in the current directory
      filesC=`find . -type f -not -path './.git/*' | wc -l`
    else
      #A normal directory
      
      #Count all directories founded in the current directory
      directoriesC=`find "$fileNameFull" -mindepth 1 -type d | wc -l`
     
      #Count all files founded in the current directory
      filesC=`find "$fileNameFull" -type f | wc -l`
    fi 
    
    if [[ "$fileNameFull" == "." ]]; then
      #WRITE THE DATA SAVEFILE
      echo "$categoryName | $directoriesC | $filesC | $size | $sizeGit | $lastGitUpdate" > "$categoryFullDir/$dataSaveDir/$dataFileName"
    fi
    
    #INDEX.HTML = Write information of the current directory in the file
    echo "<tr><td>$dirSpacer<strong><a href=\"$showedCategoryDir/$fileNameProtected/\">$showedFileName/</a></strong></td><td>$directoriesC dirs</td><td>$filesC files</td><td>$showedSize</td><td><input type=\"checkbox\" id=\"$fileIdentifier\" name=\"dirNameCB\" onclick=\"changeCheckedFiles('$fileIdentifier')\" ></td></tr>" >> "$rootPath/$htmlFile"
    
    #README.MD = Write information of the current directory in the file
    echo "| $dirSpacer**[$showedFileName/]($showedCategoryDir/$fileNameProtected)** | $directoriesC dirs | $filesC files | $showedSize |  " >> "$rootPath/$mdFile"

  elif [[ -f "$fileNameFull" ]]; then
    #The Filename is a file
    
    if [[ $dirLevel == 0 ]]; then
      #If the directory level is zero (root), give an empty path
      fileNameDir=""
    else
      #Else, remove the filename, and add a / at the end
      fileNameDir="${fileNameProtected%/*}/"
    fi

    #README.MD = Write information of the file in the file
    echo "<tr><td>$dirSpacer<a href=\"$showedCategoryDir/$fileNameProtected\">$showedFileName</a></td><td></td><td></td><td>$showedSize</td><td><input type=\"checkbox\" id=\"$fileIdentifier\" name=\"filenameCB\" data-file=\"$showedCategoryDir/$fileNameProtected\" data-path=\"$fileNameDir\" data-size=\"$size\"></td></tr>" >> "$rootPath/$htmlFile"
    
    #README.MD = Write information of the file in the file
    echo "| $dirSpacer[$showedFileName]($showedCategoryDir/$fileNameProtected) | | | $showedSize |  " >> "$rootPath/$mdFile"
  fi
  
done < "$rootPath/$categoryName.files.tmp"

#If '.git' exist, show size
if [[ -d ".git" ]]; then
  #variable for human-readable file sizes values
  showedGitSize=$(numfmt --to=iec $sizeGit)
  
  echo "<tr><td><em>(.git/)</em></td><td></td><td></td><td><em>(+$showedGitSize)</em></td><td></td></tr>" >> "$rootPath/$htmlFile"
  
  echo "| *(.git/)* |  |  | *(+$showedGitSize)* |  " >> "$rootPath/$mdFile"
fi

##INDEX.HTML : End of table
echo "</table>" >> "$rootPath/$htmlFile"

#INDEX.HTML : Add zip.js script + changeCheckedFiles function
echo "<script src=\"$showedCategoryDir/$zipScriptTarget/zip.js\"></script>" >> "$rootPath/$htmlFile"
echo "<script>" >> "$rootPath/$htmlFile"
echo "function changeCheckedFiles(idCheckbox) {" >> "$rootPath/$htmlFile"
echo "  var isChecked=document.getElementById(idCheckbox).checked;" >> "$rootPath/$htmlFile"
echo "  var checkboxes = document.querySelectorAll('[id^=\"'+idCheckbox+'.\"]');" >> "$rootPath/$htmlFile"
echo "  for(var i=0;i<checkboxes.length;i++) {" >> "$rootPath/$htmlFile"
echo "    checkboxes[i].checked=isChecked;" >> "$rootPath/$htmlFile"
echo "  }" >> "$rootPath/$htmlFile"
echo "}" >> "$rootPath/$htmlFile"
echo "" >> "$rootPath/$htmlFile"
echo "function makeZipFile() {" >> "$rootPath/$htmlFile"
echo "  var z=new Zip('resources');" >> "$rootPath/$htmlFile"
echo "  var markedCheckboxes = [];" >> "$rootPath/$htmlFile"
echo "  var filesCount=0;" >> "$rootPath/$htmlFile"
echo "  var checkboxes = document.querySelectorAll('input[type=\"checkbox\"]');" >> "$rootPath/$htmlFile"
echo "  for(var i=0;i<checkboxes.length;i++) {" >> "$rootPath/$htmlFile"
echo "    if(checkboxes[i].checked){" >> "$rootPath/$htmlFile"
echo "      markedCheckboxes.push(checkboxes[i]);" >> "$rootPath/$htmlFile"
echo "    }" >> "$rootPath/$htmlFile"
echo "  }" >> "$rootPath/$htmlFile"
echo "  for(var i=0;i<markedCheckboxes.length;i++) {" >> "$rootPath/$htmlFile"
echo "    var idName = markedCheckboxes[i].getAttribute('name');" >> "$rootPath/$htmlFile"
echo "    var fileChecked = markedCheckboxes[i].getAttribute('data-file');" >> "$rootPath/$htmlFile"
echo "    var filepath = markedCheckboxes[i].getAttribute('data-path');" >> "$rootPath/$htmlFile"
echo "    if(idName == 'filenameCB'){" >> "$rootPath/$htmlFile"
echo "      filesCount++;" >> "$rootPath/$htmlFile"
echo "      z.fecth2zip([fileChecked], filepath);" >> "$rootPath/$htmlFile"
echo "    }" >> "$rootPath/$htmlFile"
echo "  }" >> "$rootPath/$htmlFile"
echo "  var waitFilesLoadBeforeMakeZip = function(){" >> "$rootPath/$htmlFile"
echo "    if(z.filesCounted() == filesCount){" >> "$rootPath/$htmlFile"
echo "      z.makeZip();" >> "$rootPath/$htmlFile"
echo "    } else {" >> "$rootPath/$htmlFile"
echo "      setTimeout(waitFilesLoadBeforeMakeZip, 500);" >> "$rootPath/$htmlFile"
echo "    }" >> "$rootPath/$htmlFile"
echo "  }" >> "$rootPath/$htmlFile"
echo "  waitFilesLoadBeforeMakeZip();" >> "$rootPath/$htmlFile"
echo "}" >> "$rootPath/$htmlFile"
echo "</script>" >> "$rootPath/$htmlFile"

#Add a button to download files
echo "<input type=\"button\" onclick=\"makeZipFile();\" value=\"Download the files selected\">" >> "$rootPath/$htmlFile"

echo "</body>" >> "$rootPath/$htmlFile"
echo "</html>" >> "$rootPath/$htmlFile"

#Create target directory (if not exist)
if [[ ! -d "$categoryFullDir/$targetDir" ]]; then
  mkdir -p "$categoryFullDir/$targetDir"
fi
    
#Rename the temp file (remove the .tmp at end)
mv "$rootPath/$htmlFile" "$categoryFullDir/$targetDir/${htmlFile%.tmp}"
mv "$rootPath/$mdFile" "$categoryFullDir/$targetDir/${mdFile%.tmp}"

#Remove the category file list (temporary)
rm "$rootPath/$categoryName.files.tmp"

