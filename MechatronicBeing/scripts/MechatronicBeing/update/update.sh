#Update the current category AND sub-category
#call it with '?' parameter to show all the parameters 

#user safefile (save the previous option)
userSaveFile="update.sav"

#the root -RELATIVE- directory (containing all OTHER categories) used for search
#Read the information in the global file
#CHEAT : use the categoryPath instead of rootPath !!!! other scripts are IN folders, not this one !
rootDir=$(cat "_variables/categoryPath.txt")

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
masterCategory=${categoryName%-*}

#Save the path !!!! (needed for scripts executions !!!!)
rootPath=${path%/*}

#All the directories (or "categories") to update. Can include sub-directories.
targetDirs=("$categoryName") 

#change to root directory (containing all directories)
cd "$rootPath"

#Found all the sub-categories
subTargetDirs=()
showSubTargetDirs=""
for D in $categoryName*; do
  if ! [ "$D" == "$categoryName" ]; then 
    subTargetDirs+=("$D")
    showSubTargetDirs="$showSubTargetDirs $D"
  fi
done

#the MAIN directory for scripts (WORKING WITH ALL DIRECTORIES/CATEGORIES)
#WARNING : DO NOT PUT A NAME CATEGORY OR SPECIFIC DIR, OR ELSE THE SCRIPT WILL FAIL !)
scriptsDirectory="MechatronicBeing/scripts/MechatronicBeing/update"

#The directories for the Update and Git scripts
scriptsUpdateDir="$scriptsDirectory/update"
scriptsPagesDir="$scriptsDirectory/pages"
scriptsGitDir="$scriptsDirectory/git"
scriptUserDir="$scriptsDirectory/user"

#Update MB
charUpdateMB='u'
msgUpdateMBdir="update the 'MechatronicBeing' directory (from local '$masterCategory')"
scriptUpdateMBdir=("update-MBdir.sh")

#Update Fetch
charUpdateFetch='U'
msgUpdateFetch="fetch (git) all the changes (from remote '$categoryName')"
scriptUpdateFetch=("create-fetch.sh" "git-fetch.sh")

#Pages / Authors
charPagesAuthors='a'
msgPagesAuthors="update the 'pages/authors'"
scriptPagesAuthors=("pages-authors.sh" "pages-authors-full.sh")

#Pages / Downloading + Files + Detailed
charPagesDownloading='d'
msgPagesDownloading="update the 'pages/downloading'"
scriptPagesDownloading=("pages-downloading.sh" "pages-downloading-files.sh" "pages-downloading-detailed.sh")

#Pages / List
charPagesLists='l'
msgPagesLists="update the 'pages/list'"
scriptPagesLists=("pages-list.sh")

#(Pages) / Generates HTML
charHTMLstatic='h'
msgHTMLstatic="generate static html pages, from md files"
scriptHTMLstatic=("update-md2html-static.sh")

#(Pages) / Generates HTML
charHTMLdynamic='H'
msgHTMLdynamic="generate dynamic html pages (with 'md2html.js' webscript)"
scriptHTMLdynamic=("update-md2html-dynamic.sh")

#Git Commit
charGitMBdir='c'
msgGitMBdir="commit the 'MechatronicBeing' directory, to the remote repository"
scriptGitMBdir="git-MBdir.sh"

#GIT Commit All files
charGitAllFiles='C'
msgGitAllFiles="commit all the files, to the remote repository"
scriptGitAllFiles="git-Alldir.sh"

#GIT : clear the commit history
charGitClearHistory='g'
msgGitClearHistory="clear the git commit history, and commit all the files, on the remote repository"
scriptGitClearHistory="git-clearHistory.sh"

#GIT : remove the .git directory
charGitRemoveDir='G'
msgGitRemoveDir="remove the local '.git' directory"
scriptGitRemoveDir="git-removeGitDir.sh"

#Recursive options
charRecursiveOptions='r'
msgRecursiveOptions="apply the same options on the $((${#subTargetDirs[@]})) sub-$categoryName directories"

#Update + Recursive options
charRecursiveUpdate='R'
msgRecursiveUpdate="update the 'MechatronicBeing' directory (from local: $masterCategory) on the $((${#subTargetDirs[@]})) sub-$categoryName directories"

charUserScripts="[0-9]"
msgUserScripts="execute an user script"

charHelp='?'
msgHelp="show the list of parameters"

charEndScript='_'
msgEndScript="end this script [$0]"

msgGitExecuteOptions="execute Git options"
msgGenerateHTML="generate HTML files"

#Others Messages
msgDoYouWantTo="Do you want to"
msgUsePreviousOptions="use the previous options"
msgChooseYorN="Choose 'yes' or 'no' : "
msgChooseYorNorS="Choose 'yes' or 'no' or 'skip' : "
msgTypeNumberOrS="Type a number or 'skip' : "
msgTypeYesToConfirm="Type 'yes' to start the update : "

showUserScripts () {
  if [ -d "$rootPath/$categoryName/$scriptUserDir" ]; then    
    cd "$rootPath/$categoryName/$scriptUserDir"
    for((i=0;i<10;i++)); do 
      userScriptFounded=""
      #Check files or direcotry
      for _file in ${i}*; do
        if [[ $_file  =~ ^${i}[a-zA-Z].* ]]; then        
          if [[ -d "${_file}" ]]; then
            echo "  | '$i' : execute scripts inside the user directory '$_file/ "
            userScriptFounded="$_file"
            break
          elif [[ -f "${_file}" && ${_file##*.} == "sh" ]]; then
            echo "  | '$i' : execute the user script '$_file'"
            userScriptFounded="$_file"
            break
          fi
        fi
      done
      #If a script is founded, find when it will be executed
      if [[ "$userScriptFounded" != "" ]]; then
        charBeforeExecution="${userScriptFounded:1:1}"
        executedBefore=""
        case "$charBeforeExecution" in
          "$charUpdateMB" ) executedBefore="$msgUpdateMBdir";;
          "$charUpdateFetch" ) executedBefore="$msgUpdateFetch";;
          "$charPagesAuthors" ) executedBefore="$msgPagesAuthors";;
          "$charPagesDownloading" ) executedBefore="$msgPagesDownloading";;
          "$charPagesLists" ) executedBefore="$msgPagesLists";;
          "$charHTMLdynamic" ) executedBefore="$msgHTMLdynamic";;
          "$charHTMLstatic" ) executedBefore="$msgHTMLstatic";;
          "$charGitMBdir" ) executedBefore="$msgGitMBdir";;
          "$charGitAllFiles" ) executedBefore="$msgGitAllFiles";;
          "$charGitClearHistory" ) executedBefore="$msgGitClearHistory";;
          "$charGitRemoveDir" ) executedBefore="$msgGitRemoveDir";;
          "$charRecursiveOptions" ) executedBefore="$msgRecursiveOptions";;
          "$charRecursiveUpdate" ) executedBefore="$msgRecursiveUpdate";;
          "$charEndScript" ) executedBefore="$msgEndScript";;
        esac
        echo "          BEFORE this option : $executedBefore"
      fi
    done
  fi
}

showParameters () {
  echo "'$charHelp' : $msgHelp"
  echo "'$charUpdateMB' : $msgUpdateMBdir"
  echo "'$charUpdateFetch' : $msgUpdateFetch"
  echo "'$charPagesAuthors' : $msgPagesAuthors"
  echo "'$charPagesDownloading' : $msgPagesDownloading"
  echo "'$charPagesLists' : $msgPagesLists"
  echo "'$charHTMLdynamic' : $msgHTMLdynamic"
  echo "'$charHTMLstatic' : $msgHTMLstatic"
  echo "'$charGitMBdir' : $msgGitMBdir"
  echo "'$charGitAllFiles' : $msgGitAllFiles"
  echo "'$charGitClearHistory' : $msgGitClearHistory"
  echo "'$charGitRemoveDir' : $msgGitRemoveDir"
  echo "'$charRecursiveOptions' : $msgRecursiveOptions"
  echo "'$charRecursiveUpdate' : $msgRecursiveUpdate"
  echo "'$charUserScripts' : $msgUserScripts"
  showUserScripts  ##Call the function
  
}

#Save the second parameter (the "user choices")
userChoices="$1"

echo "MechatronicBeing UPDATE Script"
echo "=============================="

#if the userchoices is empty (not in the $1 parameter)
if [[ "$userChoices" == '' ]]; then

  #If a savefile exist, load the last options
  if [[ -f "$currentScriptDir/$userSaveFile" ]]; then
    userChoices=$(cat "$currentScriptDir/$userSaveFile" | cut -d' ' -f1)
    dateLastOption=$(cat "$currentScriptDir/$userSaveFile" | cut -d' ' -f2)
    hourLastOption=$(cat "$currentScriptDir/$userSaveFile" | cut -d' ' -f3)

    #Use the previous options ?
    echo "$msgDoYouWantTo $msgUsePreviousOptions (\"$0 $userChoices\" the $dateLastOption at $hourLastOption) ?" 
    while read -p "$msgChooseYorN" choice; do
      case $choice in
        [Nn]* ) userChoices=""; break;;
        [Yy]* ) break;;
      esac
    done
  
    echo ""
  fi
else
  #If ask the help '?' print the help page
  if [[ "$userChoices" == *"$charHelp"* ]]; then
    ##Call the 'help' function
    showParameters
    #exit the program
    exit
  fi
fi

#if the userchoices is empty (no parameters or no previous savefile or no wanted previous options)
if [[ "$userChoices" == '' ]]; then

  #Testing current category and the 'main'
  if ! [ "$categoryName" = "$masterCategory" ]; then 
    #Not the main, ask if we update the 'MechatronicBeing' directory
    echo "$categoryName is not the main category." 
    echo "$msgDoYouWantTo $msgUpdateMBdir  ?" 
    while read -p "$msgChooseYorN" choice; do
      case $choice in
        [Nn]* ) break;;
        [Yy]* ) userChoices="$userChoices$charUpdateMB"; break;;
      esac
    done
  fi

  #Update Pages / Authors
  echo "$msgDoYouWantTo $msgPagesAuthors ?"
  while read -p "$msgChooseYorN" choice; do
    case $choice in
      [Nn]* ) break;;
      [Yy]* ) userChoices="$userChoices$charPagesAuthors"; break;;
    esac
  done
  
  #Update Pages / Downloading
  echo "$msgDoYouWantTo $msgPagesDownloading ?"
  while read -p "$msgChooseYorN" choice; do
    case $choice in
      [Nn]* ) break;;
      [Yy]* ) userChoices="$userChoices$charPagesDownloading"; break;;
    esac
  done

  #Update Pages / Lists
  echo "$msgDoYouWantTo $msgPagesLists ?"
  while read -p "$msgChooseYorN" choice; do
    case $choice in
      [Nn]* ) break;; 
      [Yy]* ) userChoices="$userChoices$charPagesLists"; break;;
    esac
  done

  #Generate HTML
  echo "$msgDoYouWantTo $msgGenerateHTML ?"
  while read -p "$msgChooseYorN" choice1; do
    case $choice1 in
      [Nn]* ) break;;
      [Yy]* ) 
        #Ask to update the sub-categories ?
        echo " | $msgDoYouWantTo $msgHTMLstatic ?" 
        while read -p " | $msgChooseYorNorS" choice2; do
          case $choice2 in
              [Yy]* ) userChoices="$userChoices$charHTMLstatic"; break;;
              [Nn]* )
                echo "$msgDoYouWantTo $msgHTMLdynamic ?"
                while read -p "$msgChooseYorN" choice3; do
                  case $choice3 in
                    [Nn]* ) break;; 
                    [Yy]* ) userChoices="$userChoices$charHTMLdynamic"; break;;
                  esac
                done
                break;; #choice2 -> No
              [Ss]* ) break;;  #Skip: no option
          esac
        done
        break;; #choice1 -> Yes
    esac
  done

  #Recursive
  if ! [ ${#subTargetDirs[@]} -eq 0 ]; then 
    #There are sub-categories. Do we apply changes in them ?
    echo "$msgDoYouWantTo $msgRecursiveOptions ?" 
    while read -p "$msgChooseYorN" choice; do
      if [[ "$choice" == [Nn]* ]]; then
        break
      elif [[ "$choice" == [Yy]* ]]; then 
        #Ask to update the sub-categories ?
        echo " | $msgDoYouWantTo $msgRecursiveUpdate ?" 
        while read -p " | $msgChooseYorNorS" choice2; do
          case $choice2 in
              [Nn]* )         
                targetDirs=("$categoryName" ${subTargetDirs[@]});
                userChoices="$userChoices$charRecursiveOptions"; 
                break;; 
              [Yy]* ) 
                userChoices="$userChoices$charRecursiveUpdate";
                targetDirs=("$categoryName" ${subTargetDirs[@]}); 
                break;;
              [Ss]* ) break;;  #Skip: no option
          esac
        done
        break
      fi
    done
  fi
    
  #GIT options
  echo "$msgDoYouWantTo $msgGitExecuteOptions ?" 
  while read -p "$msgChooseYorN" choice1; do
    if [[ "$choice1" == [Nn]* ]]; then
      break
    elif [[ "$choice1" == [Yy]* ]]; then 
      #Commit only the MB dir ???
      echo " | $msgDoYouWantTo $msgGitMBdir ?" 
      while read -p " | $msgChooseYorNorS" choice2; do
        case $choice2 in
          [Ss]* ) break;;  #Skip : no option
          [Yy]* ) userChoices="$userChoices$msgGitMBdir"; break;;
          [Nn]* )
            #Commit all the files ???
            echo " | $msgDoYouWantTo $msgGitAllFiles ?" 
            while read -p " | $msgChooseYorNorS" choice3; do
              case $choice3 in
                  [Ss]* ) break;;  #Skip : no option
                  [Yy]* ) userChoices="$userChoices$charGitAllFiles"; break;;
                  [Nn]* )
                    #Clear commit history and commit all the files ???
                    echo " | $msgDoYouWantTo $msgGitClearHistory ?" 
                    while read -p " | $msgChooseYorNorS" choice4; do
                      case $choice4 in
                        [Ss]* ) break;;  #Skip : no option
                        [Yy]* ) userChoices="$userChoices$charGitClearHistory"; break;;
                        [Nn]* )
                          #Remove the git directory ?
                          echo " | $msgDoYouWantTo $msgGitRemoveDir ?" 
                          while read -p " | $msgChooseYorNorS" choice5; do
                            case $choice5 in
                              [Ss]* ) break;;  #Skip : no option
                              [Yy]* ) userChoices="$userChoices$charGitRemoveDir"; break;;
                              [Nn]* ) break;; 
                            esac
                          done
                          break;; #from choice4->No
                      esac
                    done
                    break;; #from choice3->No
              esac
            done
            break;; #From choice2->No
        esac
      done
      break #From choice1->yes
    fi
  done
      
  #User scripts
  echo "$msgDoYouWantTo $msgUserScripts ?" 
  while read -p "$msgChooseYorN" choice; do
    case $choice in
      [Nn]* ) break;;
      [Yy]* ) 
        #Show user scripts
        showUserScripts
        while read -p "$msgTypeNumberOrS" choice2; do
          case $choice2 in
            [Ss]* ) break;;
            [0-9]* ) userChoices="$userChoices$choice2"; break;;
          esac
        done
      break;;
    esac
  done
  
  echo ""
fi

#FINAL : CONFIRMATION OF THE OPTIONS
echo "======================"
echo "SUMMARY OF THE OPTIONS"
echo "======================"
echo "Current directory : $categoryName"
if [[ $userChoices == *$charGitRemoveDir* ]]; then
  #Note : this overwrite all other git parameters
  echo "- $msgGitRemoveDir" 
fi
if [[ $userChoices == *$charUpdateMB* ]]; then
  echo "- $msgUpdateMBdir" 
fi
if [[ $userChoices == *$charPagesAuthors* ]]; then
  echo "- $msgPagesAuthors" 
fi
if [[ $userChoices == *$charPagesDownloading* ]]; then
  echo "- $msgPagesDownloading" 
fi
if [[ $userChoices == *$charPagesLists* ]]; then
  echo "- $msgPagesLists" 
fi
if [[ $userChoices == *$charHTMLstatic* ]]; then
  echo "- $msgHTMLstatic" 
elif [[ $userChoices == *$charHTMLdynamic* ]]; then
  echo "- $msgHTMLdynamic" 
fi
if ! [[ $userChoices == *$charGitRemoveDir* ]]; then
  if [[ $userChoices == *$charGitClearHistory* ]]; then
    #Note : this overwrite all other git upload parameters (MechatronicBeing or Full)
    echo "- $msgGitClearHistory" 
  else
    if [[ $userChoices == *$charGitMBdir* ]]; then
      #Note : this overwrite the FULL git upload (just in case)
      echo "- $msgGitMBdir" 
    elif [[ $userChoices == *$charGitAllFiles* ]]; then
      echo "- $msgGitAllFiles" 
    fi
  fi
fi
if [[ $userChoices == *$charRecursiveUpdate* ]]; then
  echo "- $msgRecursiveUpdate"
fi
if [[ $userChoices == *$charRecursiveOptions* || $userChoices == *$charRecursiveUpdate* ]]; then
  echo "- $msgRecursiveOptions"
fi
echo "======="
echo "ARE YOU SURE OF THESE OPTIONS (\"$0 $userChoices\") ?"
while read -p "$msgTypeYesToConfirm" confirm; do
  if [[ $confirm == [Yy][Ee][Ss] ]]; then
    break
  else
    exit
  fi
done

#Save the options
echo "$userChoices $(date +'%Y-%m-%d %T')" > "$currentScriptDir/$userSaveFile"

#For each categories
for category in ${targetDirs[@]}; do

  #"Visual" breakline (for between (sub-)categories
  echo "[$0] --------------------------------------"
  
  #IF WANTED BY THE USER : Begin by "removing the 'git' dir"
  #because : it affect the lists....
  if [[ $userChoices == *$charGitRemoveDir* ]]; then
    if [ -d "$rootPath/$category/$scriptsGitDir" ]; then
      cd "$rootPath/$category/$scriptsGitDir"
      #if the script exist, execute it
      if [ -f "./$scriptGitRemoveDir" ]; then
        echo "[$0] '$category' : EXECUTING $scriptGitRemoveDir "
        #./$scriptGitRemoveDir
      else
        echo "[$0] '$category' : ERROR ! the script '$scriptsGitDir/$scriptGitRemoveDir' does not exist."
      fi
    fi
  fi
  
  #go to the script directory 
  if [ -d "$rootPath/$category/$scriptsUpdateDir" ]; then    
    cd "$rootPath/$category/$scriptsUpdateDir"
    
    if [[ "$userChoices" == *$charUpdateMB* && "$categoryName" == "$category" ]] || [[ "$userChoices" == *$charRecursiveUpdate* && "$categoryName" != "$category" ]]; then
      for script in ${scriptUpdateMB[@]}; do
        #if the script exist, execute it
        if [ -f "./$script" ]; then
          echo "[$0] '$category' / EXECUTING '$script'"
          ./$script
        else
          echo "[$0] '$category' : ERROR ! the script '$scriptsUpdateDir/$script' does not exist."
        fi
      done
    fi
  else
    echo "[$0] '$category' : ERROR ! $rootPath/$category/$scriptsUpdateDir/ does not exist."
  fi

  #go to the script directory 
  if [ -d "$rootPath/$category/$scriptsPagesDir" ]; then    
    cd "$rootPath/$category/$scriptsPagesDir"
    if [[ $userChoices == *$charPagesAuthors* ]]; then
      #DO PAGES-AUTHORS
      for script in ${scriptPagesAuthors[@]}; do
        #if the script exist, execute it
        if [ -f "./$script" ]; then
          echo "[$0] '$category' / EXECUTING '$script'"
          ./$script
        else
          echo "[$0] '$category' : ERROR ! the script '$scriptsPagesDir/$script' does not exist."
        fi
      done
    fi    
    if [[ $userChoices == *$charPagesDownloading* ]]; then
      #DO PAGES-DOWNLOADING
      for script in ${scriptPagesDownloading[@]}; do
        #if the script exist, execute it
        if [ -f "./$script" ]; then
          echo "[$0] '$category' / EXECUTING '$script'"
          ./$script
        else
          echo "[$0] '$category' : ERROR ! the script '$scriptsPagesDir/$script' does not exist."
        fi
      done
    fi    
    if [[ $userChoices == *$charPagesLists* ]]; then
      #Execute Pages Downloading BEFORE the lists script (data needed)
      for script in ${scriptPagesLists[@]}; do
        #if the script exist, execute it
        if [ -f "./$script" ]; then
          echo "[$0] '$category' / EXECUTING '$script'"
          ./$script
        else
          echo "[$0] '$category' : ERROR ! the script '$scriptsPagesDir/$script' does not exist."
        fi
      done
    fi

    if [[ $userChoices == *$charHTMLstatic* ]]; then
      for script in ${scriptHTMLstatic[@]}; do
        #if the script exist, execute it
        if [ -f "./$script" ]; then
          echo "[$0] '$category' / EXECUTING '$script'"
          ./$script
        else
          echo "[$0] '$category' : ERROR ! the script '$scriptsPagesDir/$script' does not exist."
        fi
      done
    elif [[ $userChoices == *$charHTMLdynamic* ]]; then
      for script in ${scriptHTMLdynamic[@]}; do
        #if the script exist, execute it
        if [ -f "./$script" ]; then
          echo "[$0] '$category' / EXECUTING '$script'"
          ./$script
        else
          echo "[$0] '$category' : ERROR ! the script '$scriptsPagesDir/$script' does not exist."
        fi
      done
    fi
  else
    echo "[$0] '$category' : ERROR ! $rootPath/$category/$scriptsPagesDir/ does not exist."
  fi
  
  #if the git directory is not removed, 
  if ! [[ $userChoices == *$charGitRemoveDir* ]]; then
    if [[ $userChoices == *$charGitMBdir* || $userChoices == *$charGitAllFiles* || $userChoices == *$charGitClearHistory* ]]; then
      msgToGitScript="(\"$0 $userChoices\" from '$category')"
      #go to the script GIT directory
      if [ -d "$rootPath/$category/$scriptsGitDir" ]; then
        cd "$rootPath/$category/$scriptsGitDir"

        if [[ $userChoices == *$charGitClearHistory* ]]; then
          if [ -f "./$scriptGitClearHistory" ]; then
            echo "[$0] '$category' / EXECUTING '$scriptGitClearHistory'"
              #./$scriptGitClearHistory $msgToGitScript
          else
            echo "[$0] '$category' : ERROR ! the script '$scriptsGitDir/$scriptGitClearHistory' does not exist."
          fi
        elif [[ $userChoices == *$charGitMBdir* ]]; then
          if [ -f "./$scriptGitMBdir" ]; then
            echo "[$0] '$category' / EXECUTING '$scriptGitMB'"
              #./$scriptGitMB $msgToGitScript
          else
            echo "[$0] '$category' : ERROR ! the script '$scriptsGitDir/$scriptGitMB' does not exist."
          fi
        elif [[ $userChoices == *$charGitAllFiles* ]]; then
          if [ -f "./$scriptGitAll" ]; then
            echo "[$0] '$category' / EXECUTING '$scriptGitAll'"
              #./$scriptGitAll $msgToGitScript
          else
            echo "[$0] '$category' : ERROR ! the script '$scriptsGitDir/$scriptGitAll' does not exist."
          fi
        fi
      else
        echo "[$0] '$category' : ERROR ! $rootPath/$category/$scriptsGitDir/ does not exist."
      fi
    fi
  fi
    
done
