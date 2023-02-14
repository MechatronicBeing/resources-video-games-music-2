# Create files with lines related for each directories starting with a same name

#DETAILED : the target Directory (FROM THE CATEGORY DIR) (for md files)
targetDetailedDir="MechatronicBeing/pages/downloading/detailed"

#DETAILED (special) : the data savefile path
dataSaveDir="MechatronicBeing/pages/downloading/files"
#DETAILED (special) : the data savefile name 
dataFileName="files.dat"

#in online repository (like github.com) : back 2 folders depth more ("tree/main")
repositoryDir="../.."

#the root -RELATIVE- directory (containing all OTHER categories) used for search
#Read the information in the global file
rootDir=$(cat "../_variables/rootPath.txt")

#DETAILED : the root -RELATIVE- directory used IN the final page [CALCULATED from the target dir]
#DETAILED :Get all the '/' (remove all others characters) in path
showedRootDirDetailed=`echo "/$targetDetailedDir" | tr -cd /`
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

#if the category name is not the "master" (the first name before '-'), 
#add the master name for listing (it can be important for "going to another category")
masterCategory=${categoryName%-*}
if ! [ "$categoryName" = "$masterCategory" ]; then 
  categories+=("$masterCategory")
fi

#Initialize variables (for data)
nameData=""
directoriesCData=0
filesCData=0
sizeData=0
sizeGitData=0
showedSize=0
showedGitSize=0
lastUpdateData=0


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
  
    #Prepare the file (with first lines)
    echo "## Detailed list of \"$categorie\"  " > "$path/detailed_$mdFile"
    echo "*Date : $(date +%F)*  " >> "$path/detailed_$mdFile"
    echo "*Note : actual values may vary !*  " >> "$path/detailed_$mdFile"
    echo "  " >> "$path/detailed_$mdFile"
    echo "| **Name** | **Directories** | **Files** | **Size** | **(+'.git' size)** | **Last commit** |  " >> "$path/detailed_$mdFile"
    echo "| -------- | --------------- | --------- | -------- | --------------- | --------------- |  " >> "$path/detailed_$mdFile"
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
      
      #Get the filename data
      if [[ -e "$D/$dataSaveDir/$dataFileName" ]]; then
        data=$(cat "$D/$dataSaveDir/$dataFileName")
        nameData=`echo "$data" | cut -d'|' -f1`
        directoriesCData=$((`echo "$data" | cut -d'|' -f2`))
        filesCData=$((`echo "$data" | cut -d'|' -f3`))
        sizeData=$((`echo "$data" | cut -d'|' -f4`))
        sizeGitData=$((`echo "$data" | cut -d'|' -f5`))
        lastUpdateData=`echo "$data" | cut -d'|' -f6`
        
        #Get the last commit date
        if [[ "$lastCommit" < "$lastUpdateData" ]]; then
          lastCommit="$lastUpdateData"
        fi
        
        #variables for human-readable file sizes
        showedSize=$(numfmt --to=iec $sizeData)
        showedGitSize=$(numfmt --to=iec $sizeGitData)
        
        #Sum
        totalDirectories=$(($totalDirectories+$directoriesCData))
        totalFiles=$(($totalFiles+$filesCData))
        totalSize=$(($totalSize+$sizeData))
        totalGitSize=$(($totalGitSize+$sizeGitData))

      else
        #DETAILED : (no data)
        directoriesCData="-"
        filesCData="-"
        lastUpdateData="-"
        showedSize="-"
        showedGitSize="-"
      fi
      
      #DETAILED : README.MD = Write information of the current directory in the file
      echo "| **[$showedNameCategory]($showedRootDirDetailed/$repositoryDir/$D/)** | $directoriesCData dirs | $filesCData files | $showedSize | *(+$showedGitSize)* | $lastUpdateData |  " >> "$path/detailed_readme.md.tmp"
      
      #DETAILED : INDEX.MD = Write information of the current directory in the file
      echo "| **[$showedNameCategory]($showedRootDirDetailed/$D/)** | $directoriesCData dirs | $filesCData files | $showedSize | *(+$showedGitSize)* | $lastUpdateData |  " >> "$path/detailed_index.md.tmp"
      
    fi
  done
  
  #DETAILED : Create target directory (if not exist)
  if [[ ! -e "$path/$categoryName/$targetDetailedDir/" ]]; then
    mkdir -p "$path/$categoryName/$targetDetailedDir/"
  fi
  
  #For the 2 filename (no difference)
  for mdFile in ${mdFiles[@]}; do
  
    #DETAILED : variables for human-readable file sizes
    showedSize=$(numfmt --to=iec $totalSize)
    showedGitSize=$(numfmt --to=iec $totalGitSize)
  
    #DETAILED : (FINAL) Write footer (totals)
    echo "| **TOTAL : $numRepositories lines** | **$totalDirectories dirs** | **$totalFiles files** | **$showedSize** | **(+$showedGitSize)** | **$lastCommit** |  " >> "$path/detailed_$mdFile"
        
    #DETAILED : Rename the temp file (remove the .tmp at end)
    mv "$path/detailed_$mdFile" "$path/$categoryName/$targetDetailedDir/${mdFile%.tmp}"
  done

done
