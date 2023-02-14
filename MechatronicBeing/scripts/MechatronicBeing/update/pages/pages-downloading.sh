# Create scripts (downloading/git clone) with lines related for each directories (starting with a same name)

#repository name
repositoryName="https://github.com/MechatronicBeing/"

#the target -RELATIVE- Directory
targetDir="MechatronicBeing/pages/downloading"

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
  echo "echo \"Download (and extract) all remote $categorie to your local\"" > "$currentScriptDir/download.sh.tmp"
  echo "echo \"GIT Clone all remote $categorie to your local\"" > "$currentScriptDir/git-clone.sh.tmp"
  
  #For each directory, with a name starting with the category
  for D in $categorie*; do
    
    #Write lines in files
    echo "curl -LO $repositoryName$D/archive/master.tar.gz" >> "$currentScriptDir/download.sh.tmp"
    echo "tar -xf master.tar.gz" >> "$currentScriptDir/download.sh.tmp"
    echo "mv $D-main $D" >> "$currentScriptDir/download.sh.tmp"
    echo "rm master.tar.gz" >> "$currentScriptDir/download.sh.tmp"
    
    echo "git clone --progress -v \"$repositoryName$D.git\"" >> "$currentScriptDir/git-clone.sh.tmp"
  done
  
  #Create target directory (if not exist)
  if [[ ! -d "$path/$categoryName/$targetDir" ]]; then
    mkdir -p "$path/$categoryName/$targetDir"
  fi

  #Rename the temp file (remove the .tmp at end)
  mv "$currentScriptDir/download.sh.tmp" "$path/$categoryName/$targetDir/download.sh"
  mv "$currentScriptDir/git-clone.sh.tmp" "$path/$categoryName/$targetDir/git-clone.sh"
  
done
