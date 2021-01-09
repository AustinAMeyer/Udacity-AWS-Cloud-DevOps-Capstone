FROM nginx:stable-alpine
COPY ./index.html /usr/share/nginx/html/index.html
RUN apk add --no-cache python3 py3-pip
RUN sudo python3 -m pip3 install awscli
EXPOSE 80