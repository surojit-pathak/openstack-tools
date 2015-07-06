function suro_edrop_log_downloader () 
{
    if [ $# -ne 2 ]; then
        printf "\nUsage:\n%s <module_name> <year>\n" $FUNCNAME
        printf "\nExample:\n%s containers 2015\n" $FUNCNAME
        return
    else 
        mod=$1
        year=$2
    fi
    rm index.html
    URL="http://eavesdrop.openstack.org/meetings/$mod/$year"
    wget $URL
    # for i in `cat index.html | grep .txt | grep -v .log.txt | cut -f6 -d\> | cut -f2 -d= | cut -f2 -d\"`; do wget $URL/$i; done
    for i in `cat index.html | grep .log.txt | cut -f6 -d\> | cut -f2 -d= | cut -f2 -d\"`; do wget $URL/$i; done
}
