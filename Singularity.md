## Why Singularity ?

While docker is probably the older and well established container
technology, there are use cases where some Docker concepts are 
show-stoppers or difficult to work around. 

msconvert will very often be used to convert MS raw data 
on a network file share such as NFS. Because docker containers 
are executed through the dockerd daemon which is by default running 
as `root` user, the container can not write the converted files 
back to the NFS share (unless you do some `uid` remapping magic, 
or run NFS as `no_root_squash`).

## Creating a singularity container from the pwiz docker container

We don't (yet ?) have a recipe to create a Singularity pwiz container image,
but here are the steps to convert the Docker image to a Singularity image.
This requires that the docker image can be pulled from a registry.
You can run an insecure ad-hoc created local registry running in a container itself:
```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

First, build the docker image as described in the README.md, and push it 
into a docker registry: 

```
docker build --tag="phnmnl/pwiz-i-agree-to-the-vendor-licenses:latest" .
docker tag phnmnl/pwiz-i-agree-to-the-vendor-licenses localhost:5000/pwiz-i-agree-to-the-vendor-licenses
docker push localhost:5000/pwiz-i-agree-to-the-vendor-licenses:latest
```

As root you can then convert the docker image with instructions in `Singularity`
into a `.simg` image. The docker registry information, image name and tag
are in that `Singularity` recipe. We need `--writable` because we need to
write to the WINEPREFIX inside the container:


```
SINGULARITY_NOHTTPS=1 singularity build --writable pwiz-i-agree-to-the-vendor-licenses.simg Singularity
```

Now you are ready to execute the `pwiz-i-agree-to-the-vendor-licenses.simg`
as a normal user. We need to specify a temporary diectory 
with `-S /mywineprefix/`, and we can optionally mount an NFS share that exists 
on the host system with `-B /nfs`. 


```
singularity exec -B /nfs -S /mywineprefix/ ./pwiz-i-agree-to-the-vendor-licenses.simg mywine msconvert /nfs/.../neg_MM8_1-A,2_01_9980.d -o $HOME/mzML`
```

