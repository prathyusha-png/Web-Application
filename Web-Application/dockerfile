FROM node:20-alpine AS build
WORKDIR /app
COPY app/package.json ./
RUN npm ci --production || true
COPY app/ .

FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=build /app ./
USER node
EXPOSE 8080
CMD ["node", "app.js"]
