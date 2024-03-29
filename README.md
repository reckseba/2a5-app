# 2a5-app

See 2a5-api first and follow "Deploy Development (locally)"

2a5-api-development 3000
2a5-db-development 5432


# Development
You need to install on your local workstation:
- git
- nodejs
- npm
- docker

Clone the repository:
```bash
git clone https://github.com/reckseba/2a5-app.git
```

Install your environment
```bash
cd 2a5-app
npm install
```

Run the nodejs development server:
```bash
npm run dev
```

Start coding and open [http://localhost:3001](http://localhost:3001) with your browser of choice to check the result. The system supports hot reload.


Stop it with CTRL+C


# Run with Docker

The container will join the existing 2a5 network
```bash
docker compose up -d
```

Stop it:
```bash
docker compose down
```

# Cleanup locally

Delete all generated files
```bash
rm -rf .next/ node_modules/ next-env.d.ts
```
