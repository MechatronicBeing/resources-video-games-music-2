# Create files with lines related for each directories starting with a same name

# the target Directory (FROM THE CATEGORY DIR) (for md files)
# WARNING : not the FINAL path !!!! '/$categoryName/' is added at the end !!!!
targetListDir="MechatronicBeing/pages/lists"

#in online repository (like github.com) : back 2 folders depth more ("tree/main")
repositoryDir="../.."

# the root -RELATIVE- directory used IN the final page [CALCULATED from the target dir]
# Get all the '/' (remove all others characters) in path
showedRootDirList=`echo "/$targetListDir" | tr -cd /`
# Add .. for each / (and add one at the beginning)
showedRootDirList="..${showedRootDirList//\//\/..}"
# EXCEPTION : add one '/..' more, as '/$categoryName/' is added at the end !!!!!
showedRootDirList="$showedRootDirList/.."

#the root -RELATIVE- directory (containing all OTHER categories) used for search
#Read the information in the global file
rootDir=$(cat "../_variables/rootPath.txt")

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

#if the category name is not the "master" (the first name before '-'), 
#add the master name for listing (it can be important for "going to another category")
masterCategory=${categoryName%-*}
if ! [ "$categoryName" = "$masterCategory" ]; then 
  categories+=("$masterCategory")
fi

#change to root directory
cd $rootDir

#for each item in categories
for categorie in ${categories[@]}; do
  
  #Initialize variables for sums and counting
  totalFiles=0
  totalDirectories=0
  totalSize=0
  totalGitSize=0
  lastCommit=0
  numRepositories=0
  
  #Write header for the 2 filename (no difference)
  for mdFile in ${mdFiles[@]}; do
    #Prepare files (with a first line)
    echo "## List of \"$categorie\"  " > "$path/list_$mdFile"
  done
  
  #For each directory, with a name starting with the category
  for D in $categorie*; do
            
    #If it's a directory
    if [[ -d "$D" ]]; then
            
      #Increase the counter of Repositories
      numRepositories=$(($numRepositories+1))
          
      #simplify the name (remove the start)          
      showedNameCategory="${D#*-}"
      if [[ "$categoryName" == "$D" ]]; then
        showedNameCategory="."
      fi
            
      # Write lines in files
      echo "[$showedNameCategory]($showedRootDirList/$repositoryDir/$D/)  " >> "$path/list_readme.md.tmp"
      echo "[$showedNameCategory]($showedRootDirList/$D/)  " >> "$path/list_index.md.tmp"
     
    fi
  done

  # Create target directory (if not exist)
  if [[ ! -e "$path/$categoryName/$targetListDir/$categoryName/" ]]; then
    mkdir -p "$path/$categoryName/$targetListDir/$categoryName/"
  fi
  
  #For the 2 filename (no difference)
  for mdFile in ${mdFiles[@]}; do
    # Rename the temp file (remove the .tmp at end)
    mv "$path/list_$mdFile" "$path/$categoryName/$targetListDir/$categoryName/${mdFile%.tmp}"
  done

done
