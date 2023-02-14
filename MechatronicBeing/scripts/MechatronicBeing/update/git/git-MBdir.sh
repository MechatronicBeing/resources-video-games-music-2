#Commit only the MechatronicBeing Folder

#the (root) category -RELATIVE- directory (containing the FILES) used for search
#Read the information in the global file
categoryDir=$(cat "../_variables/categoryPath.txt")

#keep the current script directory 
currentScriptDir=`pwd`

#Get the parameter message
msgWithCommit="$1"

#trace back previous folder to found the last directory, BEFORE the rootDir (=the last ..)
path="$currentScriptDir" 
down="$categoryDir/.."
while :; do
  test "$down" = '..' && break
  path=${path%/*}
  down=${down%/*}
done
#Take only the final folder
categoryName="${path##*/}"
#echo "Current category is : '$categoryName'"

#change to root CATEGORY directory
cd $categoryDir

#verify the presence of a '.git' directory
if [ -d ".git" ]; then
  git add --all ./MechatronicBeing
  git commit -m"Commit changes on 'MechatronicBeing' $msgWithCommit" -- ./MechatronicBeing
  git push --progress "origin" main:main

  echo "[$0] ADD, COMMIT, PUSH on $categoryName/MechatronicBeing only"
fi
