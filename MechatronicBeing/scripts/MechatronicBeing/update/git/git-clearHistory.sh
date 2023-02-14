#Clear the git commit history -by creating a new branch- (also : commit ALL files)

#the (root) category -RELATIVE- directory (containing the FILES) used for search
#Read the information in the global file
categoryDir=$(cat "../_variables/categoryPath.txt")

#keep the current script directory 
currentScriptDir=`pwd`

#Get the parameter message
msgWithCommit="$1"

#change to root CATEGORY directory
cd $categoryDir

#verify the presence of a '.git' directory
if [ -d ".git" ]; then
  #Creating a new banch (without history)
  git checkout --orphan newBranch
  #Adding the files
  git add -A 
  #Committing changes
  git commit -am "Clear commit history $msgWithCommit"
  #Deleting the main branch
  git branch -D main
  #Renaming newBranch to main
  git branch -m main
  #Push all changes
  git push -f origin main
fi
