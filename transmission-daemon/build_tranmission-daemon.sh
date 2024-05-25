#!/bin/bash

# Create "out" folder if it does not exists
if [ ! -d out ]
then
    mkdir out
fi
buildah bud --build-arg TRANSMISSION_VERSION=$TRANSMISSION_VERSION -f Containerfile.transmission --iidfile out/transmission-${TRANSMISSION_VERSION}.iid

export iid=$(cat out/transmission-${TRANSMISSION_VERSION}.iid | cut -d ':' -f2)
export container=$(buildah from ${iid})

copy_script="copy_artifacts.sh"
cat << 'EOF' >> $copy_script
#!/bin/sh
mnt=$(buildah mount $container)
cp -f $mnt/$1 ./out/$2
buildah umount $container
EOF
chmod a+x $copy_script
buildah unshare ./$copy_script transmission-${TRANSMISSION_VERSION}-obj/daemon/transmission-daemon transmission-daemon-${TRANSMISSION_VERSION}
rm ./$copy_script
buildah rm $container

# Delete out/transmission-${TRANSMISSION_VERSION}.iid if it exists
if [ -f out/transmission-${TRANSMISSION_VERSION}.iid ]
then
    rm -f out/transmission-${TRANSMISSION_VERSION}.iid
fi