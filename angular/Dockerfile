FROM node:18.20.4

RUN mkdir /angular
WORKDIR /angular
COPY package.json package-lock.json ./
RUN npm install
RUN npm install -g @angular/cli@17.3.1
COPY . .
EXPOSE 4200
CMD [ "ng", "serve", "--host", "0.0.0.0" ]
