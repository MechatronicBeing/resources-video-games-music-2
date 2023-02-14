# Create script (git-fetch) with lines related for each directories (starting with a same name)

#repository name
repositoryName="https://github.com/MechatronicBeing/"

#the target -RELATIVE- Directory
targetDir="MechatronicBeing/scripts/MechatronicBeing/update/update"

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

#Save the path !!!!
path=${path%/*}

#List of main category names
categories=("$categoryName")

#change to root directory
cd "$rootDir"

#for each item in categories
for categorie in ${categories[@]}; do

  #Prepare files (with a header / 1st line)
  echo "echo \"GIT Fetch all local $categorie from remote\"" > "$currentScriptDir/git-fetch.sh.tmp"
  
  #For each directory, with a name starting with the category
  for D in $categorie*; do    
    #Write lines in files
    echo "git --git-dir $D/.git fetch -v --progress \"origin\"" >> "$currentScriptDir/git-fetch.sh.tmp"
  done

  #Create target directory (if not exist)
  if [[ ! -d "$path/$categoryName/$targetDir" ]]; then
    mkdir -p "$path/$categoryName/$targetDir"
  fi
  
  #Rename temp files
  mv "$currentScriptDir/git-fetch.sh.tmp" "$path/$categoryName/$targetDir/git-fetch.sh"
  
done
