FROM node:21-alpine AS base

######################################################################################
# 1. Install prod dependencies only when needed
FROM base AS proddeps

# No Dev-Dependencies
ENV NODE_ENV=production

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* ./
RUN npm ci

######################################################################################
# 2. Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY components ./components
COPY lib ./lib
COPY --from=proddeps /app/node_modules ./node_modules
COPY pages ./pages
COPY public ./public
COPY styles ./styles
COPY .eslintrc.json next.config.js package-lock.json package.json postcss.config.js tailwind.config.js tsconfig.json ./
RUN npm run build

######################################################################################
# 3. Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3001

ENV PORT 3001

CMD ["node", "server.js"]

######################################################################################
# Development
FROM base AS dev

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /app

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

COPY --chown=nodejs:nodejs components ./components
COPY --chown=nodejs:nodejs lib ./lib
COPY --chown=nodejs:nodejs pages ./pages
COPY --chown=nodejs:nodejs public ./public
COPY --chown=nodejs:nodejs styles ./styles
COPY --chown=nodejs:nodejs .eslintrc.json next.config.js package-lock.json package.json postcss.config.js tailwind.config.js tsconfig.json ./

RUN npm ci
