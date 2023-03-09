#Create footer for pages-files

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../.."
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}/getGlobalValues.sh"

#keep the current script directory (= the information of $0 ONLY !!!)
currentScript="${0#./}"
currentScriptDir="${currentScript%/*}"

#INIT VARIABLES WITH GLOBAL VALUES
#the relative category path 
relativeCategoryPath=$($currentScriptDir/$globalValuesScriptname "categoryPath")
#Get the findParentDirectory script function
read -r MBfunctionsScriptsDirname findParentDirectoryScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findParentDirectoryScriptname")
#Create the call to the script later
executeFindParentDirectoryScript="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findParentDirectoryScriptname"
#Get the findRelativePath script function
read -r MBfunctionsScriptsDirname findRelativePathScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findRelativePathScriptname")
#Create the call to the script later
executeFindRelativePathScriptname="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findRelativePathScriptname"
#Get the data values
read -r dataPath dataFilesHeaderPrefix dataFilesMDfile dataFilesJSfile  <<< $($currentScriptDir/$globalValuesScriptname "filesDataPath" "dataFilesHeaderPrefix" "dataFilesMDfile" "dataFilesJSfile")
#Get the others values
read -r targetDir pagesFilesMDFilename pagesFilesHTMLFilename zipScriptTarget  <<< $($currentScriptDir/$globalValuesScriptname "pagesFilesTargetDir" "pagesFilesMDFilename" "pagesFilesHTMLFilename" "zipWebScriptTarget")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir")

#change to category directory
cd "$rootPath"

#Create target directory (if not exist)
if [[ ! -d "$categoryPath/$targetDir" ]]; then
  mkdir -p "$categoryPath/$targetDir"
fi

#Show current directory
echo "((${currentScript##*/})) CREATING FOOTER-PAGE OF FILES FOR '$categoryName'"

#ADD A PAGE FOOTER with !
#Selected X files in Y folders.
#Last modifiied
#Size
#Action : make a zip


echo "</div> <!-- _bodyContent -->" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

echo "<div id=\"_footer\" style=\"position: absolute; bottom: 0; width: 100%; height: 2.5rem;\">FOOTER</div>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

echo "</div> <!-- _bodyContainer -->" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#JS : Add zip.js script
echo "<script src=\"$showedRelativeFinalTarget/$zipScriptTarget/zip.js\"></script>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#JS : add multiples JS functions...
echo "<script>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

# echo "var markedCheckboxes = [];" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
# echo "var checkboxes = document.querySelectorAll('input[type=\"checkbox\"]');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
# echo "for(var i=0;i<checkboxes.length;i++) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
# echo "  checkboxes[i].disabled=false;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
# echo "}" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

echo "function loadData(scriptPath, executeFunction) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var newScript = document.createElement('script');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  newScript.src = scriptPath;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  newScript.type = \"text/javascript\";" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  newScript.async = true;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  document.body.appendChild(newScript);" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  newScript.addEventListener(\"load\", () => {console.log(scriptPath+' loaded.'); var fn = window[executeFunction]; if (typeof fn === \"function\") fn(); });" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "}" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#JS : Add changeCheckedItems() (when a checkbox is clicked)
echo "function changeCheckedItems(idCheckbox) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  const currentIdCheckbox='cb_'+idCheckbox+'_';" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var isChecked=document.getElementById(currentIdCheckbox).checked;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var checkboxes = document.querySelectorAll('[id^=\"cb_'+idCheckbox+'\"]');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  for(var i=0;i<checkboxes.length;i++) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    if(currentIdCheckbox != checkboxes[i].getAttribute('id')){" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      checkboxes[i].checked=isChecked;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "}" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#JS : Add changeVisibilityItems()
echo "function changeVisibilityItems(idRow) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var isVisible=(document.getElementById('&'+idRow+'_').getAttribute('isVisible')=='true');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  document.getElementById('&'+idRow+'_').setAttribute('isVisible', !isVisible);" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var elements = document.querySelectorAll('[id^=\"&'+idRow+'\"]');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var idToKeepHidden='-';" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  for(var i=0;i<elements.length;i++) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    currentID=elements[i].getAttribute('id');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    if(currentID != '&'+idRow+'_') {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      if(!(elements[i].getAttribute('isVisible')=='true')) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "         idToKeepHidden=elements[i].getAttribute('id');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      }else{" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "        if(!(currentID.startsWith(idToKeepHidden))){" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "          idToKeepHidden='-';" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "          if(isVisible) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "            elements[i].style.display='none';" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "          }else{" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "            elements[i].style.display='table-row';" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "          }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "        }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "   }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "}" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#JS : add makeZipFile()
echo "function makeZipFile() {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var z=new Zip('resources');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var markedCheckboxes = [];" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var filesCount=0;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var checkboxes = document.querySelectorAll('input[type=\"checkbox\"]');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  for(var i=0;i<checkboxes.length;i++) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    if(checkboxes[i].checked){" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      markedCheckboxes.push(checkboxes[i]);" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  for(var i=0;i<markedCheckboxes.length;i++) {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    var filename = markedCheckboxes[i].getAttribute('data-file');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    var filepath = markedCheckboxes[i].getAttribute('data-path');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    var dataExt = markedCheckboxes[i].getAttribute('data-ext');" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    if(dataExt != '/'){" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      filesCount++;" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      z.fecth2zip([filename], filepath);" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  var waitFilesLoadBeforeMakeZip = function(){" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    if(z.filesCounted() == filesCount){" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      z.makeZip();" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    } else {" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "      setTimeout(waitFilesLoadBeforeMakeZip, 500);" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "    }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  }" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "  waitFilesLoadBeforeMakeZip();" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "}" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#JS : close the script tag (for the functions)
echo "    </script>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

#Add the final tags (closing the html page)
echo "  </body>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"
echo "</html>" >> "$categoryPath/$targetDir/$pagesFilesHTMLFilename"

