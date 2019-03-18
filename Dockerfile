FROM nginx:1.15.9
MAINTAINER zfeng <i@zfeng.net>

ENV VERSION 0.0.1

WORKDIR /usr/share/nginx/html

ADD . ./

ENV NODE_ENV production

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80
