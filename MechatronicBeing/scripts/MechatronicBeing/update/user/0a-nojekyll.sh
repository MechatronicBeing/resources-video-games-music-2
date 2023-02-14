#Add a ".nojekyll" file at the root

#the root CATEGORY directory
categoryDir="../../../../.."

#change to root CATEGORY directory
cd $categoryDir

#verify the presence of the ".nojekyll" file at the root
if ! [ -f ".nojekyll" ]; then
  #add a ".nojekyll" file
  touch ".nojekyll"
fi
