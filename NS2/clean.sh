find -iname *.tr | cut -c 2- | while read line; do
    echo $line
    rm $line
done
# while `find -iname *.tr | cut -c 2-` read VAR
# do
#     echo "$VAR"
#     # rm $VAR
# done
