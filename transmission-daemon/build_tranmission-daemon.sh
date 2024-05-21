#!/bin/bash

mkdir out
export TRANSMISSION_VERSION="4.0.5"
buildah bud -f Containerfile.transmission --iidfile out/transmission-${TRANSMISSION_VERSION}.iid

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
buildah unshare ./$copy_script transmission-${TRANSMISSION_VERSION}-obj/daemon/transmission-daemon transmission-daemon-4.0.5
rm ./$copy_script
buildah rm $container
