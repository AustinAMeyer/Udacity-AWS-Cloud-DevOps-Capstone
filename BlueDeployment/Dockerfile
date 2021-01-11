FROM nginx:stable-alpine
COPY ./index.html /usr/share/nginx/html/index.html
RUN apk add --no-cache python3 py3-pip
RUN python3 -m pip install awscli
EXPOSE 80
CMD ["npm", "run", "start"]