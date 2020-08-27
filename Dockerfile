FROM land007/l4t-tensorflow:1.15.0

MAINTAINER Jia Yiqiu <yiqiujia@hotmail.com>

RUN apt-get install -y wget
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
ENV NVM_DIR=/root/.nvm
ENV SHIPPABLE_NODE_VERSION=v10.20.0
#ENV NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist
RUN echo 'export SHIPPABLE_NODE_VERSION=v10.20.0' >> /etc/profile
RUN ls $HOME/.nvm/ && chmod +x $HOME/.nvm/nvm.sh
RUN echo 'export SHIPPABLE_NODE_VERSION=v10.20.0' >> /etc/profile && \
	. $HOME/.nvm/nvm.sh && nvm install $SHIPPABLE_NODE_VERSION && nvm alias default $SHIPPABLE_NODE_VERSION && nvm use default && cd / && npm init -y && npm install -g node-gyp supervisor http-server && npm install socket.io ws express http-proxy bagpipe eventproxy chokidar request nodemailer await-signal log4js moment && \
	. $HOME/.nvm/nvm.sh && which node
ENV PATH $PATH:/root/.nvm/versions/node/$SHIPPABLE_NODE_VERSION/bin
RUN echo 'export PATH=$PATH:/root/.nvm/versions/node/$SHIPPABLE_NODE_VERSION/bin' >> /etc/profile

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y yarn pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
RUN npm install -g node-pre-gyp ts-node typescript
RUN . $HOME/.nvm/nvm.sh && cd / && npm install canvas

RUN mkdir /node
WORKDIR /node
#RUN git clone https://github.com/justadudewhohacks/face-api.js.git
ADD node /node
RUN cd /node/face-api.js/examples/examples-nodejs/ && tsc faceDetection.ts ; tsc faceRecognition.ts ; tsc faceLandmarkDetection.ts ; tsc faceRecognition.ts ; exit 0

RUN . $HOME/.nvm/nvm.sh && cd / && npm i @tensorflow/tfjs@1.5.1
RUN . $HOME/.nvm/nvm.sh && cd / && npm i @tensorflow/tfjs-node@1.5.1

RUN . $HOME/.nvm/nvm.sh && cd /node_modules/@tensorflow/tfjs-node && node-pre-gyp install --build-from-source

ADD test.js /node

#face-api.js
RUN cd /node/face-api.js/examples/examples-nodejs/ && mv package.json package.json.bak && npm init -y && npm install face-api.js

ENV TF_CPP_MIN_LOG_LEVEL=0
ENV TF_CUDA_COMPUTE_CAPABILITIES=7.2

#cat /etc/nvidia-container-runtime/host-files-for-container.d/cuda.csv
#cat /etc/nvidia-container-runtime/host-files-for-container.d/cudnn.csv
#sudo ldconfig
#sudo ln -sf /usr/lib/aarch64-linux-gnu/libcudnn.so.8 /etc/alternatives/libcudnn_so
#sudo ln -sf /usr/lib/aarch64-linux-gnu/libcudnn_static_v8.a /etc/alternatives/libcudnn_stlib

#docker build -t land007/l4t-tfjs-node:latest .
#docker run --runtime nvidia --rm -it --name l4t-tfjs1 land007/l4t-tfjs-node:latest bash