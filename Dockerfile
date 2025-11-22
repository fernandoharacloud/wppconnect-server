FROM node:22.21.1-slim AS base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN apt-get update && apt-get install -y --no-install-recommends \
  chromium \
  ca-certificates \
  fonts-liberation \
  libasound2 \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxrandr2 \
  xdg-utils \
  && rm -rf /var/lib/apt/lists/*
COPY package.json ./
RUN corepack enable && yarn install --production --pure-lockfile && yarn cache clean

FROM node:22.21.1-slim AS build
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=development PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN apt-get update && apt-get install -y --no-install-recommends \
  chromium \
  ca-certificates \
  fonts-liberation \
  libasound2 \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxrandr2 \
  xdg-utils \
  && rm -rf /var/lib/apt/lists/*
COPY package.json ./
RUN corepack enable && yarn install --production=false --pure-lockfile && yarn cache clean
COPY . .
RUN yarn build

FROM node:22.21.1-slim
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN apt-get update && apt-get install -y --no-install-recommends \
  chromium \
  ca-certificates \
  fonts-liberation \
  libasound2 \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxrandr2 \
  xdg-utils \
  && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/src/wpp-server/node_modules ./node_modules
COPY . .
COPY --from=build /usr/src/wpp-server/dist ./dist
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
