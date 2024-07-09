FROM node:20-alpine3.20

ENV HOST="0.0.0.0"
ENV PORT=3000

WORKDIR /app

COPY --chown=node:node package.json /app/package.json
COPY --chown=node:node package-lock.json /app/package-lock.json

RUN npm ci

COPY --chown=node:node . /app

RUN npm run build

USER node

CMD ["npm", "start"]
