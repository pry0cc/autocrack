ingesthash() { echo $1 >> /tmp/hashpipe & }
ingesthashfile() { for hash in $(cat $1); do echo $hash >> /tmp/hashpipe &; done }