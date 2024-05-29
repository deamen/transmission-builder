#!/bin/bash

# Check if architecture is passed as argument
if [ -z "$1" ]; then
  echo "Usage: $0 <architecture>"
  exit 1
fi

ARCH=$1

# Check if $TRANSMISSION_VERSION is set
if [ -z "$TRANSMISSION_VERSION" ]; then
  echo "TRANSMISSION_VERSION is not set"
  exit 1
fi

# Create "out" folder if it does not exist
if [ ! -d out ]; then
  mkdir out
fi

buildah bud --build-arg TRANSMISSION_VERSION=$TRANSMISSION_VERSION --platform linux/$ARCH -f Containerfile.transmission --iidfile out/transmission-${TRANSMISSION_VERSION}-${ARCH}.iid

export iid=$(cat out/transmission-${TRANSMISSION_VERSION}-${ARCH}.iid | cut -d ':' -f2)
export container=$(buildah from ${iid})

copy_script="copy_artifacts.sh"
cat << 'EOF' >> $copy_script
#!/bin/sh
mnt=$(buildah mount $container)
cp -f $mnt/$1 ./out/$2
buildah umount $container
EOF
chmod a+x $copy_script
buildah unshare ./$copy_script transmission-${TRANSMISSION_VERSION}-obj/daemon/transmission-daemon transmission-daemon-${TRANSMISSION_VERSION}-${ARCH}
rm ./$copy_script
buildah rm $container

# Delete out/transmission-${TRANSMISSION_VERSION}-${ARCH}.iid if it exists
if [ -f out/transmission-${TRANSMISSION_VERSION}-${ARCH}.iid ]; then
  rm -f out/transmission-${TRANSMISSION_VERSION}-${ARCH}.iid
fi
