#development build
FROM node:18.12.1-alpine as development
ENV NODE_ENV development
WORKDIR /react-app
COPY package*.json .
#RUN yarn config set "strict-ssl" false -g
RUN yarn config set registry https://registry.npmjs.org
RUN yarn install
COPY . . 
EXPOSE 3000
CMD [ "yarn", "start" ]

#production build
FROM node:18.12.1-alpine as production_builder
ENV NODE_ENV production
WORKDIR /react-app
COPY package*.json .
#RUN yarn config set "strict-ssl" false -g
RUN yarn config set registry https://registry.npmjs.org
#--prodcution overrides the NODE_ENV
RUN yarn install --production
COPY . . 
RUN yarn build

#production image
FROM nginx:1.22.1-alpine as production
ENV NODE_ENV production
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=production_builder /react-app/build /usr/share/nginx/html
# Expose port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]