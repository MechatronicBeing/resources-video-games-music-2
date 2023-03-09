#Used as a global variables for all the scripts !!!
#Usage(1) : variable=$(getGlobalValues.sh "variable")
#Usage(2) : read -r variable1 variable2 <<< $(getGlobalValues.sh "variable1" "variable2")

#the levels (relative path) to the MB root scripts
rootScriptsLevel="."
#keep the current script directory (= the information of $0 ONLY !!!)
currentScript="${0#./}"
currentScriptDir="${currentScript%/*}"

#Declare an associative array of "values"
declare -A valuesArray

#IMPORTANT -RELATIVE- PATH VALUES !!!!!!!!
valuesArray["categoryPath"]="../../.."  #From the update.sh dir to the root category dir
valuesArray["mainCategoryName"]="resources"
valuesArray["mainCategoryDir"]="resources"
valuesArray["mainMBdir"]="MechatronicBeing"
valuesArray["homeCategory"]="HOME"

#The current directory / repository
valuesArray["currentCategoryName"]="resources"
valuesArray["currentCategorySummary"]="Free ""public domain"" resources, for many human/machine activities."

#Online repository
valuesArray["repositoryDirAdjust"]="../.."
valuesArray["repositoryDirChange"]="tree/main"
valuesArray["repositoryFileChange"]="blob/main"
valuesArray["onlineRepositoryName"]="https://github.com/MechatronicBeing/"
valuesArray["onlineArchiveZipFile"]="archive/refs/heads/main.zip"
valuesArray["onlineArchiveTgzFile"]="archive/refs/heads/main.tar.gz"
valuesArray["onlinePagesUrl"]="https://mechatronicbeing.github.io/"
valuesArray["onlineContact"]="MechatronicBeing![](MechatronicBeing/images/symbols/other/atsign.png)![](MechatronicBeing/images/symbols/bf/g.png)![](MechatronicBeing/images/symbols/bf/m.png)![](MechatronicBeing/images/symbols/bf/a.png)![](MechatronicBeing/images/symbols/bf/i.png)![](MechatronicBeing/images/symbols/bf/l.png)![](MechatronicBeing/images/symbols/other/centerdot.png)![](MechatronicBeing/images/symbols/bf/c.png)![](MechatronicBeing/images/symbols/bf/o.png)![](MechatronicBeing/images/symbols/bf/m.png)"


#MB FUNCTIONS SCRIPTS
valuesArray["MBfunctionsScriptsDirname"]="_functions"
valuesArray["trimLeadingSpacesScriptname"]="trimLeadingSpaces.sh"
valuesArray["trimTrailingSpacesScriptname"]="trimTrailingSpaces.sh"
valuesArray["trimSpacesScriptname"]="trimSpaces.sh"
valuesArray["findParentDirectoryScriptname"]="findParentDirectory.sh"
valuesArray["findRelativePathScriptname"]="findRelativePath.sh"

#MB SCRIPTS
valuesArray["MBscriptsDir"]="${valuesArray[""mainMBdir""]}/scripts/_MechatronicBeing"
valuesArray["MBupdateScriptname"]="update.sh"
valuesArray["userSaveFile"]="update.sav" 

#Sub-directories scripts (used by update.sh)
valuesArray["scriptsUpdateDataDirname"]="data"
valuesArray["scriptsUpdateFilesDirname"]="files"
valuesArray["scriptsUpdatePagesDirname"]="pages"
valuesArray["scriptsUseGitDirname"]="git"

#Scripts names (called by update.sh)
valuesArray["dataWorksScriptname"]="data-works.sh"
valuesArray["dataFilesScriptname"]="data-files.sh"
valuesArray["updateScriptsScriptname"]="files-scripts.sh"
valuesArray["updateMBdirScriptname"]="update-MBdir.sh"
valuesArray["createFetch"]="create-fetch.sh"
valuesArray["pagesAuthorsScriptname"]="pages-authors.sh"
valuesArray["pagesOtherScriptname"]="pages-other.sh"
valuesArray["updateHtmlScriptname"]="md2html.sh"
valuesArray["gitMDdirScriptname"]="git-MBdir.sh"
valuesArray["gitAllDirScriptname"]="git-Alldir.sh"
valuesArray["gitClearHistoryScriptname"]="git-clearHistory.sh"
valuesArray["gitRemoveGitDirScriptname"]="git-removeGitDir.sh"
valuesArray["recursiveScriptname"]="recursive.sh"

valuesArray["fileIconDir"]="${valuesArray[""mainMBdir""]}/images/tango-icon-library"
valuesArray["fileIconSizeDir"]="32x32"

#DATA FILES
valuesArray["dataFilesSubScriptsDirname"]="data-files/"
valuesArray["dataFilesHeadersScriptname"]="data-files-headers.sh"
valuesArray["dataFilesContentScriptname"]="data-files-content.sh"
valuesArray["dataPath"]="${valuesArray[""mainMBdir""]}/data"
valuesArray["filesDataPath"]="${valuesArray[""dataPath""]}/files"
valuesArray["dataFilesHeaderPrefix"]="headers/"
valuesArray["dataFilesRawfile"]="files.txt"
valuesArray["dataFilesMDfile"]="files.md_"
valuesArray["dataFilesHTMLfile"]="files.htm_"
valuesArray["dataFilesJSfile"]="files.js"
valuesArray["dataGitRawfile"]="git.txt"
valuesArray["dataGitMDfile"]="git.md_"
valuesArray["dataGitHTMLfile"]="git.htm_"
valuesArray["dataWorksFilename"]="works.lst"
valuesArray["mechatronicBeingFile"]="MechatronicBeing.md"

#FILES : CREATE SCRIPTS
valuesArray["scriptsDir"]="${valuesArray[""mainMBdir""]}/scripts"
valuesArray["downloadZipFilename"]="download-zip.sh"
valuesArray["downloadTgzFilename"]="download-tgz.sh"
valuesArray["gitCloneFilename"]="git-clone.sh"
valuesArray["gitFetchFilename"]="git-fetch.sh"

#STYLES FOR PAGES
valuesArray["MBStylesDir"]="${valuesArray[""mainMBdir""]}/styles"
valuesArray["filesStyleFilename"]="files.css"

#PAGES : MD2HTML
valuesArray["updateHtmlSubScriptsDir"]="md2html/"
valuesArray["updateHtmlStaticScriptname"]="md2html-static.sh"
valuesArray["updateHtmlDynamicScriptname"]="update-md2html-dynamic.sh"
valuesArray["updateHtmlDynamicWebDirname"]="${valuesArray[""mainMBdir""]}/scripts/web/md2html"
valuesArray["updateHtmlDynamicWebScriptname"]="md2html.js"
valuesArray["readme2indexScriptname"]="rename-readme2index.sh"
valuesArray["readme2indexFilename"]="rename-readme2index.lst"

#PAGES-AUTHORS
valuesArray["pageAuthorsDir"]="${valuesArray[""mainMBdir""]}/pages/authors"

#PAGES-FILES
valuesArray["pagesFilesScriptname"]="pages-files.sh"
valuesArray["pagesFilesSubDirname"]="pages-files/"
valuesArray["pagesFilesHeaderSubScriptname"]="pages-files-header.sh"
valuesArray["pagesFilesContentSubScriptname"]="pages-files-content.sh"
valuesArray["pagesFilesFooterSubScriptname"]="pages-files-footer.sh"
valuesArray["pagesFilesTargetDir"]="${valuesArray[""mainMBdir""]}/pages/files"
valuesArray["pagesFilesIconsDir"]="${valuesArray[""mainMBdir""]}/images/icons"
valuesArray["pagesFilesIconsExt"]=".png"
valuesArray["pagesFilesMDFilename"]="readme.md"
valuesArray["pagesFilesHTMLFilename"]="index.html"
valuesArray["zipWebScriptTarget"]="${valuesArray[""mainMBdir""]}/scripts/web/zip"

#Pages-OTHER
valuesArray["pagesOtherSubScriptDir"]="pages-other/"
valuesArray["pagesOtherRootSubScriptname"]="pages-root.sh"
valuesArray["pagesOtherListSubScriptname"]="pages-list.sh"
#Pages-OTHER : ROOT
valuesArray["rootTemplateFilename"]="rootTemplate.txt"
valuesArray["rootPagesScriptname"]="pages-root.sh"
valuesArray["rootPagesDirname"]="."
valuesArray["rootMDfilename"]="readme.md"
#Pages-OTHER : LIST
valuesArray["pageListDir"]="${valuesArray[""mainMBdir""]}/pages/list"

#Some specials characters
valuesArray["escapeSpacesInUrl"]="%20"
valuesArray["htmlSpacer"]="&nbsp;"
valuesArray["spacerTimes"]="5"

# #Create the call to the script later
# executeFindParentDirectoryScript="$currentScriptDir/$rootScriptsLevel/${valuesArray[""MBfunctionsScriptsDirname""]}/${valuesArray[""findParentDirectoryScriptname""]}"

# ##Found the important paths
# categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/${valuesArray[""categoryPath""]}")
# #Take only the final folder (the categoryName)
# valuesArray["currentCategoryPath"]="${categoryPath##*/}"
# #Take only the final folder (the categoryName)
# valuesArray["currentCategoryName"]="${categoryPath##*/}"
# #Move one folder and save the rootPath for later !!!
# valuesArray["currentRootPath"]="${categoryPath##*/}"

##################################################
result=""
val=""
#For each parameters (=variables) ask, found the value
for var in "$@"; do
  #If the variable name exist, get the value !
  if [[ -v "valuesArray[$var]" ]]; then
    val="${valuesArray[$var]}"
  else
    #Else, the variable is not present
    val="ERROR-VARIABLE-'$var'-DOES-NOT-EXIST"
  fi
  
  #add the value to the result values
  if [[ "$result" == "" ]]; then
    result="$val"
  else
    result="$result $val"
  fi
done

#return the values
echo "$result"
