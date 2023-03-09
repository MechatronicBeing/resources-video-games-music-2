#Find the parent directory, from a path (in $1 parameter) and a relative "back-path" (in $2, ex:'../../..').
#A stopBefore value ($3) can be used to stop before the XX directory

#get parameters
path="$1" 
downPath="$2"
stopBefore=$(("$3"))

#Get the levels of the back-folders
#Simplify the path : from ".." to "."
#change all '..' to '+' char
step1="${downPath//../+}"
#Remove all characters '.' single and / (not wanted)
step2="${step1//[^\+]/}"
#count the level (=numbers of . character)
levels=$((${#step2}))

#For each levels (minus the $2 parameter)
for (( i=0 ; i<(levels-stopBefore); i++)); do
  path="${path%/*}"
done

#Return the path
echo "$path"