#Remove the .git directory

#the (root) category -RELATIVE- directory (containing the FILES) used for search
#Read the information in the global file
categoryDir=$(cat "../_variables/categoryPath.txt")

#change to root CATEGORY directory
cd $categoryDir

#verify the presence of a '.git' directory
if [ -d ".git" ]; then
  #remove the directory
  rm -rf ".git"
fi
