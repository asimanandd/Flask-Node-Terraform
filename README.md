# Flask + Node.js DevOps Mini Project

## Overview
This project demonstrates a simple multi-service architecture using:
- Node.js with Express as the frontend
- Flask as the backend
- Docker and Docker Compose for containerization

The frontend serves an HTML form, and the backend processes form submissions.

---

## Project Structure
Flask-node-devops/
├── Backend/
│ ├── app.py
│ ├── requirements.txt
│ ├── Dockerfile
│ └── .gitignore
│
├── Frontend/
│ ├── server.js
│ ├── package.json
│ ├── Dockerfile
│ ├── views/
│ │ └── form.ejs
│ └── .gitignore
│
├── docker-compose.yml
└── README.md


---

## Technologies Used
- Node.js
- Express
- Flask
- Docker
- Docker Compose

---

## How to Run the Project

### Prerequisites
- Docker Desktop installed and running

### Steps
```bash
docker-compose up --build
