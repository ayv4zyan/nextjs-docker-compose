FROM node:18-alpine

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* bun.lockb* ./
# Omit --production flag for TypeScript devDependencies
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  elif [ -f bun.lockb ]; then bun install; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn install; \
  fi

COPY src ./src
COPY public ./public
# Copy all config files.
COPY *config.* .

# Disable Next.js telemetry
RUN \
  if [ -f yarn.lock ]; then yarn next telemetry disable; \
  elif [ -f package-lock.json ]; then npx next telemetry disable; \
  elif [ -f pnpm-lock.yaml ]; then pnpm exec next telemetry disable; \
  elif [ -f bun.lockb ]; then bun next telemetry disable; \
  else npx next telemetry disable; \
  fi

# Build Next.js based on the preferred package manager
RUN \
  if [ -f yarn.lock ]; then yarn build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm build; \
  elif [ -f bun.lockb* ]; then bun run build; \
  else npm run build; \
  fi

# Start Next.js based on the preferred package manager
CMD \
  if [ -f yarn.lock ]; then yarn start; \
  elif [ -f package-lock.json ]; then npm run start; \
  elif [ -f pnpm-lock.yaml ]; then pnpm start; \
  elif [ -f bun.lockb ]; then bun run start; \
  else npm run start; \
  fi
