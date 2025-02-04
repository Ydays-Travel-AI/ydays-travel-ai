FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
RUN npm run build --configuration=production

FROM builder as final-stage
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .
EXPOSE 4000
CMD ["node", "./dist/next-step/server/server.mjs"]