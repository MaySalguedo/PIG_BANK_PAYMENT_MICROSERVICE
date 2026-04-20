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

<li>

<strong>Load the catalog</strong>

<ul>

<li>

<strong>Get your AWS Account id</strong>

```bash
aws sts get-caller-identity --query Account --output text
```

</li>

<li>

<strong>Load csv</strong>

With your id account (must be a number) ejecute the following command

```bash
aws s3 cp catalog.csv s3://pig-bank-catalog-uploads-YOUR_ID_ACCOUNT/
```

</li>

</ul>

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
## 📡 API Endpoints

--

## 1. Start a Payment
 
**`POST /payments`**
 
Creates a new payment record with `IN_PROGRESS` status and enqueues the event in SQS for asynchronous processing.
 
### Request Body
 
```json
{
  "cardId": "string",
  "service": {
    "id": "number",
    "category": "string",
    "provider": "string",
    "service": "string",
    "plan": "string",
    "monthly_price": "number",
    "details": "string",
    "status": "Active | Inactive"
  }
}
```
 
| Field | Type | Required | Description |
|---|---|---|---|
| `cardId` | `string` | ✅ | User's card identifier |
| `service.id` | `number` | ✅ | Service ID from the catalog |
| `service.category` | `string` | ✅ | Service category (e.g. `"Internet"`) |
| `service.provider` | `string` | ✅ | Provider name |
| `service.service` | `string` | ✅ | Service name |
| `service.plan` | `string` | ✅ | Contracted plan name |
| `service.monthly_price` | `number` | ✅ | Monthly price in the configured currency |
| `service.details` | `string` | ✅ | Additional details (e.g. speed) |
| `service.status` | `string` | ✅ | Service status: `Active` or `Inactive` |
 
### Response `201 Created`
 
```json
{
  "traceId": "generated-uuid"
}
```
 
### Response `500 Internal Server Error`
 
```json
{
  "message": "error description"
}
```
 
---
 
## 2. Get Transaction Status
 
**`GET /payments/{traceId}`**
 
Returns the current status of a transaction by its `traceId`.
 
### Path Parameters
 
| Parameter | Type | Required | Description |
|---|---|---|---|
| `traceId` | `string` | ✅ | UUID of the transaction to look up |
 
### Request Body
 
_Not applicable._
 
### Response `200 OK`
 
```json
{
  "uuid": "string",
  "traceId": "string",
  "userId": "string",
  "cardId": "string",
  "service": { "..." },
  "status": "IN_PROGRESS | FINISH | FAILED",
  "timestamp": "string",
  "createdAt": "string",
  "error": "string | undefined"
}
```
 
### Response `400 Bad Request`
 
```json
{
  "message": "traceId required"
}
```
 
### Response `404 Not Found`
 
```json
{
  "message": "Transaction not found"
}
```
 
---
 
## 3. Get Service Catalog
 
**`GET /catalog`**
 
Returns the full list of available services stored in Redis.
 
### Request Body
 
_Not applicable._
 
### Response `200 OK`
 
```json
[
  {
    "id": "number",
    "category": "string",
    "provider": "string",
    "service": "string",
    "plan": "string",
    "monthly_price": "number",
    "details": "string",
    "status": "Active | Inactive"
  }
]
```
 
### Response `500 Internal Server Error`
 
```json
{
  "message": "Internal error",
  "detail": "error description"
}
```
 
---
 
## 4. Sync Catalog (Manual)
 
**`POST /catalog/sync`**
 
> ⚠️ **Warning:** This endpoint directly invokes `sync-catalog-lambda`, whose handler is designed to receive an `S3Event`. Calling it from API Gateway **does not replace** the automatic S3 trigger and may require payload adaptation.
 
The recommended flow to sync the catalog is to upload the `.csv` file directly to the S3 bucket:
 
```bash
aws s3 cp catalog.csv s3://pig-bank-catalog-uploads-{YOUR_ACCOUNT_ID}/
```
 
### Request Body (internally expected S3Event)
 
```json
{
  "Records": [
    {
      "s3": {
        "bucket": {
          "name": "pig-bank-catalog-uploads-{ACCOUNT_ID}"
        },
        "object": {
          "key": "catalog.csv"
        }
      }
    }
  ]
}
```
 
### Response `200`
 
_No body. The lambda processes the file and saves the catalog to Redis._
 
---
 
## ⚡ Internal Triggers (No HTTP Endpoint)
 
### `transaction-lambda` — Trigger: SQS
 
Consumes messages published by `start-payment-lambda`. The expected message structure in the queue is:
 
```json
{
  "data": {
    "traceId": "string"
  }
}
```
 
Fetches the payment from DynamoDB, calls the bank API, and updates the status to `FINISH` or `FAILED`.
 
---
 
### `sync-catalog-lambda` — Trigger: S3 Event
 
Fires automatically when a `.csv` is uploaded to the `pig-bank-catalog-uploads-{ACCOUNT_ID}` bucket. Parses the file and saves the catalog to Redis with the following column mapping:
 
| CSV Column | Redis Field |
|---|---|
| `ID` | `id` |
| `Categoría` | `category` |
| `Proveedor` | `provider` |
| `Servicio` | `service` |
| `Plan` | `plan` |
| `Precio Mensual` | `monthly_price` |
| `Velocidad/Detalles` | `details` |
| `Estado` | `status` (`Activo` → `Active`) |
 