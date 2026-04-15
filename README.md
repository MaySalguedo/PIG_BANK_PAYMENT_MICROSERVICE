<div align="center">

<h1>🐷 PIG BANK 🐷</h1>

<h3 style="margin-top: -10px; font-weight: normal;">
PAYMENT MICROSERVICE
</h3>

<br/>

<img src="https://img.shields.io/badge/AWS-%23232F3E.svg?style=for-the-badge&logo=amazon-aws&logoColor=white"/>
<img src="https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white"/>
<img src="https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white"/>
<img src="https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white"/>

</div>

## 🎯 Overview

**Pig Bank Payment Microservice** is a core component of the Pig Bank ecosystem, designed to handle the lifecycle 
of payments. Built with **Clean Architecture** (Hexagonal) principles, it ensures high scalability and 
decoupling between business logic and cloud infrastructure. It processes card requests, manages payments 
states, and integrates with notification systems.

## ✨ Key Features

### 🛠️ Card Orchestration
- **Dynamic Request Processing**: Handles incoming card requests through AWS Lambda and API Gateway.
- **Automated Validation**: Implements domain logic to calculate limits and validate user eligibility.

### ☁️ Cloud-Native Integration
- **Serverless Compute**: Fully powered by AWS Lambda for cost-efficient scaling.
- **NoSQL Persistence**: Leverages Amazon DynamoDB for ultra-low latency data storage.
- **Event-Driven Messaging**: Integrated with AWS SQS for asynchronous notification dispatching.

### 🏗️ Enterprise-Grade Architecture
- **Hexagonal Layers**: Strict separation between `Domain` (Core logic), `App` (Use cases), and `Infra` (External Adapters).
- **Port & Adapter Pattern**: Facilitates swapping infrastructure (e.g., changing databases) without affecting business rules.

## 🏗️ Project Structure

The microservice follows a strict Clean Architecture layout:

```text
src/
├── app/
│   └── services/            # Use Cases (Business workflows)
├── domain/
│   ├── entities/            # Core Domain Models (Card, Transaction)
│   ├── interfaces/          # Ports (Repository & Service contracts)
│   │   ├── query/           # Read operations
│   │   └── statement/       # Write operations (Command side)
│   ├── models/              # DTOs and Data Models
│   └── types/               # Custom types and Enums (CardType)
└── infra/
    ├── adapters/            # Infrastructure implementations (DynamoDB, SQS)
    └── handlers/            # Entry points (AWS Lambda handlers)
```

## 🚀 Getting Started

### Prerequisites

<ul>

<li><strong>Node.js</strong> 24+</li>
<li><strong>AWS CLI</strong> configured with appropriate permissions.</li>
<li><strong>Terraform</strong v1.5.0+ for infrastructure provisioning.></li>

</ul>

### 🛠️ Installation & Setup

<ol>

<li>

<strong>Clone the repository</strong>

```bash
git clone https://github.com/MaySalguedo/PIG_BANK_PAYMENT_MICROSERVICE.git
cd PIG_BANK_PAYMENT_MICROSERVICE
npm install
```

</li>

<li>

<strong>Compile the project</strong>

```bash
# Bundles TypeScript files and resolves Path Aliases (@services, @adapters, etc.)
# Builds the lambda.zip for terraform
npm run compile
```

</li>

<li>

<strong>Deploy Infrastructure</strong>

```bash
terraform apply
```

Or you can also **compile**, **init** _(Optional)_ and **deploy** with the following command

```bash
# use deploy:init to init terraform as well
npm run deploy
```

</li>

</ol>

## 🛠️ Tech Stack

<ol>

<li><strong>Runtime:</strong> Node.js with TypeScript for type-safe development.</li>
<li><strong>Bundler:</strong> esbuild for high-performance Lambda packaging.</li>
<li><strong>Database:</strong> Amazon DynamoDB (Single Table Design).</li>
<li><strong>Messaging:</strong> AWS SQS (Simple Queue Service) for cross-service communication.</li>

</ol>

## Environment Configuration
Create a `terraform.tfvars` on the root directory with the following contend
```env
# API Configuration
card_service_api_url = "https://your.card.microservice.url.amazonaws.com/prod"
```
