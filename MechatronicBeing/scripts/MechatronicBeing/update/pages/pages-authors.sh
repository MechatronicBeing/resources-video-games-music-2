# Create files with lines related for the current category

#the target Directory (FROM THE CATEGORY DIR) (for md files)
targetAuthorsDir="MechatronicBeing/pages/authors"

#the reading Directory (FROM THE CATEGORY DIR) (for md files)
readingAuthorListDir="MechatronicBeing/pages/authors"
readingAuthorListFile="authors.lst"

#the main file for authors in ALL MechatronicBeing resources
mechatronicBeingFile="MechatronicBeing.md"

#Headers used in the Authors list
listFileHeader1="| **Author** | **Website** | **Work** | Licence(s) |  " 
listFileHeader2="| ---------- | ----------- | -------- | ---------- |  " 

#in online repository (like github.com) : back 2 folders depth more ("tree/main")
repositoryDir="../.."

#In case of names with spaces, replace the " " with "%20"
spaceEscape="%20"

#The filename to the temporary list
tmpAuthorList="authorsList.tmp"

#the (root) category -RELATIVE- directory (containing the FILES) used for search
#Read the information in the global file
categoryDir=$(cat "../_variables/categoryPath.txt")

#the root -RELATIVE- directory used IN the final page [CALCULATED from the target dir]
#Get all the '/' (remove all others characters) in path
showedCategoryDirList=`echo "$targetAuthorsDir" | tr -cd /`
#Add .. for each / (and add one at the beginning)
showedCategoryDirList="..${showedCategoryDirList//\//\/..}"

#keep the current script directory 
currentScriptDir=`pwd`

#track back previous folder to found the last directory, BEFORE the rootDir (=the last ..)
path="$currentScriptDir" 
down="$categoryDir"
while :; do
  test "$down" = '..' && break
  path=${path%/*}
  down=${down%/*}
done
#Remove the last '..' to get the category path (full)
categoryFullDir="${path%/*}"
#Take only the final folder
categoryName="${categoryFullDir##*/}"
#Take the root path
rootPath="${categoryFullDir%/*}"

#The 2 md files
mdFiles=("readme.md.tmp" "index.md.tmp")

#change to root directory
cd "$categoryDir"

echo "" > "$path/$tmpAuthorList"

find . -type f -iname "$mechatronicBeingFile" | while read mbFile; do 
  #get all informations
  authorName=""
  authorWebsite=""
  authorWorkName=""
  authorLicenses=""
  
  #Get the path (remove ./ at start from find, and remove the filename)
  authorWorkPath="${mbFile#./}"
  #Remove the filename
  authorWorkPath="${authorWorkPath%/*}"
  
  #Read the file to found the data
  while read line; do 
    #Take the only 15 first characters AND uppercase the result
    startLine=${line:0:15}
    startLine=${startLine^^}
    #If the variable is not founded AND start with the keyword
    if [[ $authorName == "" && $startLine =~ AUTHOR ]]; then
      authorName="${line#*:}"
    elif [[ $authorLicenses == "" && $startLine =~ LICENSE ]]; then
      authorLicenses="${line#*:}"
    elif [[ $authorWebsite == "" && $startLine =~ WEBSITE ]]; then
      authorWebsite="${line#*:}"
    elif [[ $authorWorkName == "" && $startLine =~ NAME ]]; then
      authorWorkName="${line#*:}"
    fi
    
    #If all data is founded, stop reading the file
    if [[ $authorName != "" && $authorLicenses != "" && $authorWebsite != "" && $authorWorkName != "" ]]; then
      break
    fi
  done < "$mbFile"
  
  #If the work name is not founded, add the name folder.
  if [[ $authorWorkName == "" ]]; then
    authorWorkName="${authorWorkPath##*/}"
  fi
  
  #TRIM LEFT SPACES
  showedAuthorName="${authorName## }"
  showedAuthorWebsite="${authorWebsite## }"
  showedAuthorWorkName="${authorWorkName## }"
  showedAuthorLicenses="${authorLicenses## }"
  
  #remove the trailing CR.
  showedAuthorName="${showedAuthorName%$'\r'}"
  showedAuthorWebsite="${showedAuthorWebsite%$'\r'}"
  showedAuthorWorkName="${showedAuthorWorkName%$'\r'}"
  showedAuthorLicenses="${showedAuthorLicenses%$'\r'}"
  
  #TRIM RIGHT SPACES
  showedAuthorName="${showedAuthorName%% }"
  showedAuthorWebsite="${showedAuthorWebsite%% }"
  showedAuthorWorkName="${showedAuthorWorkName%% }"
  showedAuthorLicenses="${showedAuthorLicenses%% }"
  
  echo "$showedAuthorName | $showedAuthorWebsite | $showedAuthorWorkName | $authorWorkPath/ | $showedAuthorLicenses" >> "$path/$tmpAuthorList"
done

#Sort alphabetically the author list in a file, and remove the temporary file. 
cat "$path/$tmpAuthorList" | sort -k1 > "$readingAuthorListDir/$readingAuthorListFile"
rm "$path/$tmpAuthorList"

#If the file authors exist, generate the content 
if [[ -e "$readingAuthorListDir/$readingAuthorListFile" ]]; then

  #Write header for the 2 filename (no difference)
  for mdFile in ${mdFiles[@]}; do

    echo "## List of authors and works in \"$categoryName\"  " > "$rootPath/authors_$mdFile"
    echo "  " >> "$rootPath/authors_$mdFile"
    echo "$listFileHeader1" >> "$rootPath/authors_$mdFile"
    echo "$listFileHeader2" >> "$rootPath/authors_$mdFile"
  done
  
  #Read the the list of authors
  while read line; do 
  
    #If the line is not empty
    if [[ $line != "" ]]; then
      #get all informations
      authorName=`echo "$line" | cut -d'|' -f1`
      authorWebsite=`echo "$line" | cut -d'|' -f2`
      authorWorkName=`echo "$line" | cut -d'|' -f3`
      authorWorkPath=`echo "$line" | cut -d'|' -f4`
      authorLicenses=`echo "$line" | cut -d'|' -f5`
      
      #TRIM LEFT SPACES
      showedAuthorName="${authorName## }"
      showedAuthorWebsite="${authorWebsite## }"
      showedAuthorWorkName="${authorWorkName## }"
      showedAuthorWorkPath="${authorWorkPath## }"
      showedAuthorLicenses="${authorLicenses## }"

      #TRIM RIGHT SPACES
      showedAuthorName="${showedAuthorName%% }"
      showedAuthorWebsite="${showedAuthorWebsite%% }"
      showedAuthorWorkName="${showedAuthorWorkName%% }"
      showedAuthorWorkPath="${showedAuthorWorkPath%% }"
      showedAuthorLicenses="${showedAuthorLicenses%% }"
      
      #Protect (from spaces) the 
      showedAuthorWorkPath="${showedAuthorWorkPath// /$spaceEscape}"
      
      #Write to INDEX (normal path)
      echo "| **$showedAuthorName** | $showedAuthorWebsite | [$showedAuthorWorkName]($showedCategoryDirList/$showedAuthorWorkPath) | $showedAuthorLicenses" >> "$rootPath/authors_index.md.tmp"
      
      #Write to README (Add repository path with the normal path !!)
      echo "| **$showedAuthorName** | $showedAuthorWebsite | [$showedAuthorWorkName]($showedCategoryDirList/$repositoryDir/$showedAuthorWorkPath) | $showedAuthorLicenses" >> "$rootPath/authors_readme.md.tmp"
      
    fi
  done < "$readingAuthorListDir/$readingAuthorListFile"

fi


#Create target directory (if not exist)
if [[ ! -e "$targetAuthorsDir/" ]]; then
  mkdir -p "$targetAuthorsDir/"
fi

#For the 2 filename (no difference)
for mdFile in ${mdFiles[@]}; do
  #move the files
  mv "$rootPath/authors_$mdFile" "$targetAuthorsDir/${mdFile%.tmp}"
done
