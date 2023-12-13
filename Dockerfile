FROM node:18 AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY --link package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm config set registry http://registry.npmjs.org/
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi


# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps --link /app/node_modules ./node_modules
COPY --link  . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
# ENV NEXT_TELEMETRY_DISABLED 1

ENV UPLOADTHING_SECRET=<your UPLOADTHING_SECRET>
ENV UPLOADTHING_APP_ID=<your UPLOADTHING_APP_ID>

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app
# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED 1

RUN \
  addgroup --system --gid 1001 nodejs; \
  adduser --system --uid 1001 nextjs

COPY --from=builder --link /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --link --chown=1001:1001 /app/.next/standalone ./
COPY --from=builder --link --chown=1001:1001 /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000
# ENV HOSTNAME localhost
ENV NODE_ENV=production
ENV UPLOADTHING_SECRET=<your UPLOADTHING_SECRET>
ENV UPLOADTHING_APP_ID=<your UPLOADTHING_APP_ID>

# Allow the running process to write model files to the cache folder.
# NOTE: In practice, you would probably want to pre-download the model files to avoid having to download them on-the-fly.
RUN mkdir -p /app/node_modules/@xenova/.cache/
RUN chmod 777 -R /app/node_modules/@xenova/

CMD ["node", "server.js"]