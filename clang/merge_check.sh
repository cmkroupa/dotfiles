CONFLICT_FILES=$(git diff --cached --name-only | xargs grep -l "^<<<<<<< \|^=======$\|^>>>>>>> " 2>/dev/null)
 
if [ -n "$CONFLICT_FILES" ]; then
    echo "Merge conflict markers found in:"
    echo "$CONFLICT_FILES"
    exit 1
fi
 
exit 0
 
