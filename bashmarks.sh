# Bashmarks is a simple set of bash functions that allows you to bookmark
# folders in the command-line.
#
# To install, put bashmarks.sh somewhere such as ~/bin, then source it
# in your .bashrc file (or other bash startup file):
#   source ~/bin/bashmarks.sh
#
# To bookmark a folder, simply go to that folder, then bookmark it like so:
#   bookmark foo
#
# The bookmark will be named "foo"
#
# When you want to get back to that folder use:
#   go foo
#
# To see a list of bookmarks:
#   bookmarksshow
#
# Tab completion works, to go to the shoobie bookmark:
#   go sho[tab]
#
# Your bookmarks are stored in the ~/.bookmarks file

bookmarks_file=~/.bookmarks

# Create bookmarks_file it if it doesn't exist
if [[ ! -f $bookmarks_file ]]; then
  touch $bookmarks_file
fi

bookmark (){
  bookmark_name=$1

  if [[ -z $bookmark_name ]]; then
    echo 'Invalid name, please provide a name for your bookmark. For example:'
    echo '  bookmark foo'
  else
    bookmark="`pwd`|$bookmark_name" # Store the bookmark as folder|name

    if [[ -z `grep "|$bookmark_name" $bookmarks_file` ]]; then
      echo $bookmark >> $bookmarks_file
      echo "Bookmark '$bookmark_name' saved"
    else
      echo "Bookmark '$bookmark_name' already exists. Replace it? (y or n)"
      while read replace
      do
        if [[ $replace = "y" ]]; then
          # Delete existing bookmark
          sed "/.*|$bookmark_name/d" $bookmarks_file > ~/.tmp && mv ~/.tmp $bookmarks_file
          # Save new bookmark
          echo $bookmark >> $bookmarks_file
          echo "Bookmark '$bookmark_name' saved"
          break
        elif [[ $replace = "n" ]]; then
          break
        else
          echo "Please type 'y' or 'n'"
        fi
      done
    fi
  fi
}

# Delete the named bookmark from the list
bookmarkdelete (){
  bookmark_name=$1

  if [[ -z $bookmark_name ]]; then
    echo 'Invalid name, please provide the name of the bookmark to delete.'
  else
    bookmark=`grep "|$bookmark_name$" "$bookmarks_file"`

    if [[ -z $bookmark ]]; then
      echo 'Invalid name, please provide a valid bookmark name.'
    else
      cat $bookmarks_file | grep -v "|$bookmark_name$" $bookmarks_file > bookmarks_temp && mv bookmarks_temp $bookmarks_file
      echo "Bookmark '$bookmark_name' deleted"
    fi
  fi
}

# Show a list of the bookmarks
bookmarksshow (){
  cat $bookmarks_file | awk '{ printf "%-40s%-40s%s\n",$1,$2,$3}' FS=\|
}

go(){
  bookmark_name=$1

  bookmark=`grep "|$bookmark_name$" "$bookmarks_file"`

  if [[ -z $bookmark ]]; then
    echo 'Invalid name, please provide a valid bookmark name. For example:'
    echo '  go foo'
    echo
    echo 'To bookmark a folder, go to the folder then do this (naming the bookmark 'foo'):'
    echo '  bookmark foo'
  else
    dir=`echo "$bookmark" | cut -d\| -f1`
    cd "$dir"
  fi
}

_go_complete(){
  # Get a list of bookmark names, then grep for what was entered to narrow the list
  cat $bookmarks_file | cut -d\| -f2 | grep "$2.*"
}

complete -C _go_complete -o default go
