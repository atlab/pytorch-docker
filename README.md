# Repository for Toliaslab Pytorch Docker image
This repository contains information and configuration needed to build Docker images for PyTorch development as used in Tolias Lab. Example docker-compose file for running jupyter notebook in the docker container are also included.  
To run the jupyter service in the docker compose file and connect to datajoint server, you should have your own .env file in the same folder as the example below:  

## .env file example  
```
DJ_HOST=your-datajoint-host-address
DJ_USER=your-datajonit-username
DJ_PASS=your-datajoint-password
JUPYTER_PASSWORD=set-a-password-for-your-jupyter-notebook
```