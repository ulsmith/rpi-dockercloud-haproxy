# ulsmith/rpi-dockercloud-haproxy


Taken from the original dockercloud/haproxy image, rejiggered for rpi on a pi2 (arm7). This was done mainly due to all the goodness dockercloud adds to haproxy such as dynamic assignment much like traefik does. Used mainly with containers to allow container endpoints to be assigned to host rules. If you require more basic haproxy needs, such as routing to fixed IP's in a multi server setup (if not using swarm) then try ulsmith/rpi-haproxy.


For information using this image, please refer to dockercloud docs here [https://hub.docker.com/r/dockercloud/haproxy/] and here [https://github.com/docker/dockercloud-haproxy].


## Version

Currently mdae from 1.5.1 of dockercloud/haproxy
