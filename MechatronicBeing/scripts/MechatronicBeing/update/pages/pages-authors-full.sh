# Create files with lines related for each directories starting with a same name
#1st pass : collect all the data in a file
#2nt pass : write the data in the final page

#the target Directory (FROM THE CATEGORY DIR) (for md files)
targetAuthorsDir="MechatronicBeing/pages/authors/full"

#the reading Directory (FROM THE CATEGORY DIR) (for md files)
readingAuthorListDir="MechatronicBeing/pages/authors"
readingAuthorListFile="authors.lst"

#Headers used in the Authors list
listFileHeader1="| **Name** | **Website** | **Category** | **Work** | Licence(s) |  " 
listFileHeader2="| -------- | ----------- | ------------ | -------- | ---------- |  " 

#in online repository (like github.com) : back 2 folders depth more ("tree/main")
repositoryDir="../.."

#The filename to the temporary list
tmpFullList="full_authors.tmp"
tmpSortedFullList="sorted_full_authors.tmp"

#the root -RELATIVE- directory (containing all OTHER categories) used for search
#Read the information in the global file
rootDir=$(cat "../_variables/rootPath.txt")

#DETAILED : the root -RELATIVE- directory used IN the final page [CALCULATED from the target dir]
#DETAILED :Get all the '/' (remove all others characters) in path
showedRootDirDetailed=`echo "/$targetAuthorsDir" | tr -cd /`
#DETAILED :Add .. for each / (and add one at the beginning)
showedRootDirDetailed="..${showedRootDirDetailed//\//\/..}"

#keep the current script directory 
currentScriptDir=`pwd`

#track back previous folder to found the last directory, BEFORE the rootDir (=the last ..)
path="$currentScriptDir" 
down="$rootDir"
while :; do
  test "$down" = '..' && break
  path=${path%/*}
  down=${down%/*}
done
#Take only the final folder
categoryName="${path##*/}"

#Remove the category and save the path for later !!!
path=${path%/*}

#List of main category names
categories=("$categoryName")

#The 2 md files
mdFiles=("readme.md.tmp" "index.md.tmp")

#change to root directory
cd $rootDir

#for each item in categories
for categorie in ${categories[@]}; do
  
  #For each directory, with a name starting with the category
  for D in $categorie*; do
            
    #If it's a directory
    if [[ -d "$D" ]]; then

      #If the file authors exist, write a new list
      if [[ -e "$D/$readingAuthorListDir/$readingAuthorListFile" ]]; then

        #Read the the list of authors
        while read line; do 
        
          #if the line is not empty
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
            
            #Write the line with the category added
            echo "$showedAuthorName | $showedAuthorWebsite | $D | $showedAuthorWorkName | $showedAuthorWorkPath | $showedAuthorLicenses" >> "$path/$tmpFullList"
          fi
        done < "$D/$readingAuthorListDir/$readingAuthorListFile"

      fi
    fi
  done
done

#Create target directory (if not exist)
if [[ ! -e "$path/$categoryName/$targetAuthorsDir/" ]]; then
  mkdir -p "$path/$categoryName/$targetAuthorsDir/"
fi

#If the file authors exist, generate the content 
if [[ -e "$path/$tmpFullList" ]]; then

  #Write header for the 2 filename (no difference)
  for mdFile in ${mdFiles[@]}; do
    echo "## List of all authors and works in \"$categorie\"  " > "$path/authors_$mdFile"
    echo "  " >> "$path/authors_$mdFile"
    echo "$listFileHeader1" >> "$path/authors_$mdFile"
    echo "$listFileHeader2" >> "$path/authors_$mdFile"
  done
  
  cat "$path/$tmpFullList" | sort -k1 > "$path/$tmpSortedFullList"
  
  #Read the the list of authors
  while read line; do 
    #get all informations
    authorName=`echo "$line" | cut -d'|' -f1`
    authorWebsite=`echo "$line" | cut -d'|' -f2`
    authorCategory=`echo "$line" | cut -d'|' -f3`
    authorWorkName=`echo "$line" | cut -d'|' -f4`
    authorWorkPath=`echo "$line" | cut -d'|' -f5`
    authorLicenses=`echo "$line" | cut -d'|' -f6`
    
    #TRIM LEFT SPACES
    showedAuthorName="${authorName## }"
    showedAuthorWebsite="${authorWebsite## }"
    showedAuthorCategory="${authorCategory## }"
    showedAuthorWorkName="${authorWorkName## }"
    showedAuthorWorkPath="${authorWorkPath## }"
    showedAuthorLicenses="${authorLicenses## }"

    #TRIM RIGHT SPACES
    showedAuthorName="${showedAuthorName%% }"
    showedAuthorWebsite="${showedAuthorWebsite%% }"
    showedAuthorCategory="${showedAuthorCategory%% }"
    showedAuthorWorkName="${showedAuthorWorkName%% }"
    showedAuthorWorkPath="${showedAuthorWorkPath%% }"
    showedAuthorLicenses="${showedAuthorLicenses%% }"
  
    #change the category path (needed if multiples path)
    showedCategoryPath="$showedRootDirDetailed/$showedAuthorCategory/"
    
    #Protect (from spaces) the author path work
    showedAuthorWorkPath="$showedCategoryPath${showedAuthorWorkPath// /$spaceEscape}"

    #simplify the name (remove the start)          
    showedNameCategory="${showedAuthorCategory#*-}"
    if [[ "$categoryName" == "$showedNameCategory" ]]; then
      showedNameCategory="."
    fi
    
    #Write to INDEX (normal path)
    echo "| **$showedAuthorName** | $showedAuthorWebsite | [$showedNameCategory]($showedCategoryPath) | [$showedAuthorWorkName]($showedAuthorWorkPath) | $showedAuthorLicenses" >> "$path/authors_index.md.tmp"
    
    #Write to README (Add repository path with the normal path !!)
    echo "| **$showedAuthorName** | $showedAuthorWebsite | [$showedNameCategory]($showedCategoryPath) | [$showedAuthorWorkName]($repositoryDir/$showedAuthorWorkPath) | $showedAuthorLicenses" >> "$path/authors_readme.md.tmp"
    
  done < "$path/$tmpSortedFullList"

fi

#For the 2 filename (no difference)
for mdFile in ${mdFiles[@]}; do
  #move the files
  mv "$path/authors_$mdFile" "$path/$categoryName/$targetAuthorsDir/${mdFile%.tmp}"
done

#Remove temporary files
rm "$path/$tmpFullList" 
rm "$path/$tmpSortedFullList"



